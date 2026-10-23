import os
import pathlib
import re
import unittest

import lxml.etree as ET

from mmd_utils.polygon import polygon_problems, ring_orientation, unwrap_ring

NS = 'xmlns:mmd="http://www.met.no/schema/mmd" xmlns:gml="http://www.opengis.net/gml"'


def mmd_polygon(points, holes=(), srs='EPSG:4326'):
    """ mmd:polygon element with positions written as given (lat lon for EPSG:4326) """
    def ring(pts):
        pos = ''.join('<gml:pos>%s %s</gml:pos>' % p for p in pts)
        return '<gml:LinearRing>%s</gml:LinearRing>' % pos
    interiors = ''.join('<gml:interior>%s</gml:interior>' % ring(h) for h in holes)
    xml = ('<mmd:polygon %s><gml:Polygon id="polygon" srsName="%s">'
           '<gml:exterior>%s</gml:exterior>%s</gml:Polygon></mmd:polygon>'
           % (NS, srs, ring(points), interiors))
    return ET.fromstring(xml)


# A Sentinel-1 frame as delivered (lat lon), corners clockwise
CLOCKWISE_FRAME = [(65.381798, 9.476668), (65.835999, 4.134038), (67.431908, 4.803319),
                   (66.960785, 10.486644), (65.381798, 9.476668)]
# Bering Sea, anticlockwise along the edges that cross the antimeridian
ANTIMERIDIAN = [(55.0, 170.0), (55.0, -170.0), (62.0, -170.0), (62.0, 170.0), (55.0, 170.0)]


class TestRingOrientation(unittest.TestCase):

    def test_unwrap_across_antimeridian(self):
        ring, winding = unwrap_ring([(170, 50), (-170, 50), (-170, 60), (170, 60)])
        self.assertEqual(winding, 0)
        self.assertEqual([lon for lon, _ in ring], [170, 190, 190, 170])

    def test_unwrap_round_a_pole(self):
        eastward = [(-180, 80), (-90, 80), (0, 80), (90, 80)]
        self.assertEqual(unwrap_ring(eastward)[1], 360)
        self.assertEqual(unwrap_ring(eastward[::-1])[1], -360)

    def test_orientation(self):
        square = [(0, 60), (10, 60), (10, 70), (0, 70)]
        self.assertEqual(ring_orientation(square), 'anticlockwise')
        self.assertEqual(ring_orientation(square[::-1]), 'clockwise')

    def test_orientation_across_antimeridian(self):
        # plain-longitude shoelace would say clockwise; along the shortest
        # paths it is anticlockwise
        ring = [(170, 55), (-170, 55), (-170, 62), (170, 62)]
        self.assertEqual(ring_orientation(ring), 'anticlockwise')
        self.assertEqual(ring_orientation(ring[::-1]), 'clockwise')

    def test_orientation_round_the_poles(self):
        eastward = [(-180, 80), (-90, 80), (0, 80), (90, 80)]
        self.assertEqual(ring_orientation(eastward), 'anticlockwise')
        self.assertEqual(ring_orientation(eastward[::-1]), 'clockwise')
        westward_south = [(90, -75), (0, -75), (-90, -75), (-180, -75)]
        self.assertEqual(ring_orientation(westward_south), 'anticlockwise')
        self.assertEqual(ring_orientation(westward_south[::-1]), 'clockwise')


class TestPolygonProblems(unittest.TestCase):

    def test_clockwise_exterior_is_reported(self):
        problems = polygon_problems(mmd_polygon(CLOCKWISE_FRAME))
        self.assertEqual(len(problems), 1)
        self.assertIn('exterior ring is clockwise', problems[0])

    def test_anticlockwise_exterior_passes(self):
        self.assertEqual(polygon_problems(mmd_polygon(CLOCKWISE_FRAME[::-1])), [])

    def test_antimeridian(self):
        self.assertEqual(polygon_problems(mmd_polygon(ANTIMERIDIAN)), [])
        self.assertEqual(len(polygon_problems(mmd_polygon(ANTIMERIDIAN[::-1]))), 1)

    def test_hole_must_be_clockwise(self):
        outer = [(60, 0), (60, 10), (70, 10), (70, 0), (60, 0)]
        hole = [(62, 2), (68, 2), (68, 8), (62, 8), (62, 2)]
        self.assertEqual(polygon_problems(mmd_polygon(outer, holes=[hole])), [])
        problems = polygon_problems(mmd_polygon(outer, holes=[hole[::-1]]))
        self.assertEqual(len(problems), 1)
        self.assertIn('interior ring', problems[0])

    def test_crs84_positions_are_lon_lat(self):
        lon_lat = [(lon, lat) for lat, lon in CLOCKWISE_FRAME[::-1]]
        self.assertEqual(polygon_problems(mmd_polygon(lon_lat, srs='CRS:84')), [])

    def test_lon_lat_written_as_lat_lon_is_reported(self):
        # "-180 -90" in EPSG:4326 is latitude -180: the axes are swapped
        swapped = [(-180, -90), (180, -90), (180, 90), (-180, 90), (-180, -90)]
        problems = polygon_problems(mmd_polygon(swapped))
        self.assertEqual(len(problems), 1)
        self.assertIn('outside -90:90', problems[0])

    def test_unknown_crs_is_not_judged(self):
        self.assertEqual(polygon_problems(mmd_polygon(CLOCKWISE_FRAME, srs='EPSG:3413')), [])

    def test_pos_list(self):
        flat = ' '.join('%s %s' % p for p in CLOCKWISE_FRAME)
        xml = ('<mmd:polygon %s><gml:Polygon srsName="EPSG:4326"><gml:exterior><gml:LinearRing>'
               '<gml:posList srsDimension="2">%s</gml:posList></gml:LinearRing></gml:exterior>'
               '</gml:Polygon></mmd:polygon>' % (NS, flat))
        self.assertEqual(len(polygon_problems(ET.fromstring(xml))), 1)


class TestSpecificationExamples(unittest.TestCase):

    def test_polygon_examples_are_valid_and_anticlockwise(self):
        doc = os.path.join(pathlib.Path.cwd(), 'doc', 'ch02-md-elements-geographic_extent.adoc')
        text = open(doc, encoding='utf-8').read()
        examples = re.findall(r'----\n(<geographic_extent>.*?</geographic_extent>)\n----',
                              text, re.S)
        with_polygon = [e for e in examples if '<polygon>' in e]
        self.assertGreaterEqual(len(with_polygon), 2)
        for example in with_polygon:
            # well-formed once the namespaces are declared
            root = ET.fromstring(
                '<mmd xmlns="http://www.met.no/schema/mmd" '
                'xmlns:gml="http://www.opengis.net/gml">%s</mmd>' % example)
            polygon = root.find('.//{http://www.met.no/schema/mmd}polygon')
            self.assertEqual(polygon_problems(polygon), [], example)


if __name__ == '__main__':
    unittest.main()
