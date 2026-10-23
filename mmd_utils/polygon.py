""" Ring orientation of geographic_extent/polygon.

The MMD specification (geographic_extent/polygon) requires the exterior ring
of the GML polygon to be anticlockwise, with the covered area on the
left-hand side, and interior rings (holes) to be clockwise. Consecutive
positions are joined along the shortest path, so a polygon crossing the
antimeridian is judged along the edges that cross it, and a ring going once
round a pole must keep that pole on its left.

In EPSG:4326 positions are written "latitude longitude".
"""

# srsName values whose positions are "latitude longitude" or "longitude latitude"
LAT_LON = ('EPSG:4326', 'urn:ogc:def:crs:EPSG::4326',
           'http://www.opengis.net/def/crs/EPSG/0/4326')
LON_LAT = ('CRS:84', 'urn:ogc:def:crs:OGC:1.3:CRS84',
           'http://www.opengis.net/def/crs/OGC/1.3/CRS84')


def _local(tag):
    """ Element name without its namespace (GML 3.1 and 3.2 alike) """
    return tag.rsplit('}', 1)[-1]


def unwrap_ring(points):
    """ Unwrap the longitudes of a ring so that no edge is longer than 180 degrees.

    Args:
        points: ring positions as (longitude, latitude), closed or not
    Returns:
        (unwrapped open ring, winding), where the winding is the total change
        of longitude round the ring: 0 for an ordinary ring, +360 or -360
        for a ring that goes once round a pole
    """
    points = [(float(lon), float(lat)) for lon, lat in points]
    if len(points) > 1 and points[0] == points[-1]:
        points = points[:-1]
    unwrapped = [points[0]]
    for lon, lat in points[1:]:
        previous = unwrapped[-1][0]
        unwrapped.append((lon + 360.0 * round((previous - lon) / 360.0), lat))
    # The closing edge also takes the shortest path; what is left over is
    # whole turns round a pole.
    first = unwrapped[0][0]
    last = unwrapped[-1][0]
    return unwrapped, round(360.0 * round((last - first) / 360.0))


def ring_orientation(points):
    """ 'anticlockwise' or 'clockwise', judged along the shortest paths between positions.

    Args:
        points: ring positions as (longitude, latitude)
    """
    ring, winding = unwrap_ring(points)
    if winding == 0:
        closed = ring + ring[:1]
        area = sum(x0 * y1 - x1 * y0 for (x0, y0), (x1, y1) in zip(closed, closed[1:]))
        return 'anticlockwise' if area > 0 else 'clockwise'
    # A ring round a pole: the pole is on the left when it goes eastward
    # round the North Pole, or westward round the South Pole.
    north = sum(lat for _lon, lat in ring) >= 0
    return 'anticlockwise' if (winding > 0) == north else 'clockwise'


def _positions(ring, lat_lon):
    """ Positions of a gml:LinearRing as (longitude, latitude) """
    coordinates = []
    for element in ring.iter():
        name = _local(element.tag)
        if name not in ('pos', 'posList') or not element.text:
            continue
        values = [float(v) for v in element.text.split()]
        if name == 'pos':
            coordinates.append(values[:2])
        else:
            dimension = int(element.get('srsDimension', 2))
            coordinates.extend(values[i:i + 2] for i in range(0, len(values), dimension))
    return [(b, a) if lat_lon else (a, b) for a, b in coordinates]


def polygon_problems(polygon):
    """ Orientation problems of a geographic_extent/polygon element.

    Args:
        polygon: the mmd:polygon element (lxml)
    Returns:
        list of messages; empty when the rings are oriented as required, or
        when the coordinate reference system is not one whose axis order is known
    """
    problems = []
    for gml_polygon in polygon.iter():
        if _local(gml_polygon.tag) != 'Polygon':
            continue
        srs = gml_polygon.get('srsName', 'EPSG:4326')
        if srs not in LAT_LON + LON_LAT:
            continue
        for boundary in gml_polygon:
            kind = _local(boundary.tag)
            if kind not in ('exterior', 'interior'):
                continue
            points = _positions(boundary, srs in LAT_LON)
            if len(points) < 3:
                problems.append('%s ring has fewer than 3 positions' % kind)
                continue
            bad_lats = [lat for _lon, lat in points if not -90 <= lat <= 90]
            if bad_lats:
                order = 'latitude longitude' if srs in LAT_LON else 'longitude latitude'
                problems.append(
                    '%s ring has latitude %s, outside -90:90; in %s positions are "%s"'
                    % (kind, bad_lats[0], srs, order))
                continue
            expected = 'anticlockwise' if kind == 'exterior' else 'clockwise'
            found = ring_orientation(points)
            if found != expected:
                problems.append(
                    '%s ring is %s; it must be %s (see geographic_extent/polygon)'
                    % (kind, found, expected))
    return problems
