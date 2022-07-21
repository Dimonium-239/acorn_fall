class Helpers {
  static double rotator(double rotateAngle, double speedOfRotation,
      [bool byClock = true]) {
    if (speedOfRotation < 0 || speedOfRotation > 0.05) {
      speedOfRotation = 0;
    }
    if (byClock) {
      rotateAngle += speedOfRotation;
    } else {
      rotateAngle -= speedOfRotation;
    }
    if (rotateAngle > 360) {
      rotateAngle = 0;
    }
    if (rotateAngle < 0) {
      rotateAngle = 360;
    }
    return rotateAngle;
  }
}
