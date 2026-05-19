class Point {
  double x, y;
  Point(this.x, this.y);
}

class ScannerUtils {
  /// Finds the 4 outermost corners (top-left, top-right, bottom-right, bottom-left)
  /// from a 2D binary segmentation mask.
  static List<Point> findCorners(
      List<List<double>> mask, int width, int height) {
    double minSum = double.infinity, maxSum = -double.infinity;
    double minDiff = double.infinity, maxDiff = -double.infinity;

    Point tl = Point(0, 0),
        tr = Point(0, 0),
        bl = Point(0, 0),
        br = Point(0, 0);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (mask[y][x] > 0.5) {
          // Threshold for document foreground
          double sum = x + y.toDouble();
          double diff = y - x.toDouble();

          if (sum < minSum) {
            minSum = sum;
            tl = Point(x.toDouble(), y.toDouble());
          }
          if (sum > maxSum) {
            maxSum = sum;
            br = Point(x.toDouble(), y.toDouble());
          }

          // y - x is minimized when x is large and y is small (Top-Right)
          if (diff < minDiff) {
            minDiff = diff;
            tr = Point(x.toDouble(), y.toDouble());
          }
          // y - x is maximized when x is small and y is large (Bottom-Left)
          if (diff > maxDiff) {
            maxDiff = diff;
            bl = Point(x.toDouble(), y.toDouble());
          }
        }
      }
    }

    return [tl, tr, br, bl];
  }
}
