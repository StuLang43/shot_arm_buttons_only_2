import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:control_pad/control_pad.dart';
import 'package:string_splitter/string_splitter_io.dart';
import 'dart:math';
import 'dart:async';
import "package:vector_math/vector_math.dart" as vec;
import "package:bezier/bezier.dart";
import 'package:flutter/services.dart';
import 'package:rename/rename.dart';
//import 'package:connectivity/connectivity.dart'
// show Connectivity, ConnectivityResult;
//import 'package:wifi_info_flutter/wifi_info_flutter.dart';

//import 'package:advanced_splashscreen/advanced_splashscreen.dart';

bool WIFIConnect=true;

void main() async {

  //exit(0);cd..
//  Socket sock = await Socket.connect('192.168.0.1',23);



//https://github.com/pauldemarco/flutter_blue/issues/299
//note: must enable "location permissions" in order for wifi connection to work in release mode. edit android/app/src/main/AndroidManifest.xml
//explained here https://github.com/johnwargo/flutter-android-connectivity-permissions



  Socket sock = await Socket.connect('192.168.0.1',23)
      .timeout(Duration(seconds: 5),onTimeout: (){
    print('Connection to GRBL_ESP time out');
    WIFIConnect=false;

    //exit(0);//close app
  });

  // We need to call it manually,
  // because we going to call setPreferredOrientations()
  // before the runApp() call
  WidgetsFlutterBinding.ensureInitialized();

  // Than we setup preferred orientations,
  // and only after it finished we run our app
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((value) => runApp(MyApp(sock)));
  //runApp(MyApp(sock));
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  Socket socket;
  MyApp(Socket s){
    //MyApp(){
    this.socket=s;
  }






  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:   MyHomePage(
        title: 'Home Page',
        channel: socket,
      ),
      /*
      AdvancedSplashScreen(
        seconds: 3,
        colorList: [Color(0xff0088e2), Color(0xff0075cd), Color(0xff0063b8)],
        appTitle: "Dash Cam",
      ),
*/
    );
  }



}


class threePointCircle{
  double x1,y1,x2,y2,x3,y3;
  double xc,yc,rc;
  threePointCircle(this.x1,this.y1,this.x2,this.y2,this.x3,this.y3){
    xc=((pow(x1,2)+pow(y1,2))*(y2-y3)+(pow(x2,2)+pow(y2,2))*(y3-y1)+(pow(x3,2)+pow(y3,2))*(y1-y2))/(2*(x1*(y2-y3)-y1*(x2-x3)+x2*y3-x3*y2));
    yc=((pow(x1,2)+pow(y1,2))*(x3-x2)+(pow(x2,2)+pow(y2,2))*(x1-x3)+(pow(x3,2)+pow(y3,2))*(x2-x1))/(2*(x1*(y2-y3)-y1*(x2-x3)+x2*y3-x3*y2));
    rc=sqrt(pow(xc-x1,2)+pow(yc-y1,2));
  }


}
class xYZPosition {
  double x;
  double y;
  double z;
  double theta1;
  double theta2;

  xYZPosition(this.theta1, this.theta2) {
    double theta3;
    double theta;
    double s;
    double r = 190;
    print('theta1=${theta1}, theta2=${theta2}');

    theta3 = (180 - theta2.abs()) / 2;
    print('theta3=${theta3}');

    theta = theta1 - theta2.sign * theta3;
    print('theta=${theta}');

    s = (2 * r * sin(theta2 / 2 * 2 * pi / 360)).abs();
    print('s=${s}');

    x = s * cos(theta * 2 * pi / 360);
    print('x=${x}');

    y = s * sin(theta * 2 * pi / 360);
    print('y=${y}');
    print('  ');

  }
}

class MotorSpeed {
  //C:\Users\blue123\OneDrive\ShotArmCalcs.jpg
  //all distance units are in mm
  //all time units are in seconds
  double shoulderAngle;
  double elbowAngle;
  double wristAngle;
  double shoulderSpeed;
  double elbowSpeed;
  double wristSpeed;
  double r = 190;
  double xa;
  double ya;
  double xb;
  double yb;
  double anga;
  double angb;
  double shoulderAngleStart;
  double speed;
  bool leftMode = true;
  double oldShoulderAngle;
  double oldElbowAngle;
  double sAng1, sAng2, eAng1, eAng2, wAng1, wAng2;
  double shoulder_mm, elbow_mm, wrist_mm;


  MotorSpeed(this.xa, this.ya, this.xb, this.yb, this.anga, this.angb,
      this.shoulderAngleStart, this.speed) {
    //void calcSpeeds(){


    double shoulderStepsPerDegree = 5333.333;//1333;
    double elbowStepsPerDegree = 5333.333;// 1333;
    double wristStepsPerDegree =  5333.333;//1333;
    double time;

    double stepsPermm = 100;//grbl steps per mm

    print('anga=${anga}');
    print('angb=${angb}');

    time = sqrt(pow(xb - xa, 2) + pow(yb - ya, 2)) / speed;
    // print('${xa}');

    calcAngles2(xa, ya, anga, shoulderAngleStart);

    sAng1 = shoulderAngle;
    eAng1 = elbowAngle;
    wAng1 = wristAngle;

    calcAngles2(xb, yb, angb, sAng1);
    sAng2 = shoulderAngle;
    eAng2 = elbowAngle;
    wAng2 = wristAngle;

    shoulderSpeed = (sAng2 - sAng1) * shoulderStepsPerDegree / time / stepsPermm;

    elbowSpeed = (eAng2 - eAng1) * elbowStepsPerDegree / time / stepsPermm;

    wristSpeed = (wAng2 - wAng1) * wristStepsPerDegree / time / stepsPermm;

    shoulder_mm = sAng2* shoulderStepsPerDegree / stepsPermm;
    elbow_mm = eAng2* elbowStepsPerDegree / stepsPermm;
    wrist_mm = wAng2* wristStepsPerDegree / stepsPermm;

    if (xa == 0 && ya == 0) if (xb < 0)
      leftMode = true;
    else
      leftMode = false;
  }


  void calcAngles2(double x, double y, double ang, double lastShoulderAngle) {
    double pi = 3.1415926535897932;
    double theta, theta1, theta2, theta3, s;
    double  shoulderAngle1, shoulderAngle2, theta31, theta32;
    //  print('start calc angles');
    s = sqrt(pow(x, 2) + pow(y, 2));

    if (y > 0)
      theta = acos(x / s) * 360 / (2 * pi);
    else
      theta = -acos(x / s) * 360 / (2 * pi);
    print('theta=${theta}');
    // print('start calc angles');
    elbowAngle = 2 * asin(s / (2 * r)) * 360 / (2 * pi);

    theta31 = (180 - elbowAngle) / 2;
    print('theta31=${theta31}');
    //theta32 = (180 + elbowAngle) / 2;
    // print('theta32=${theta32}');

    print('ang=${ang}');
    shoulderAngle1 = theta + theta31;
    shoulderAngle2 = theta - theta31;  //was: shoulderAngle2 = theta + theta32;

    /*
    if(shoulderAngle1>90) shoulderAngle1=shoulderAngle1-360;
    if(shoulderAngle2>90) shoulderAngle2=shoulderAngle2-360;
    if(elbowAngle>180) elbowAngle=elbowAngle-360;
    if(elbowAngle<-180) elbowAngle=elbowAngle+360;
*/

//print('start calc angles');
    print('LastshoulderAngle=${lastShoulderAngle}');
    if ((shoulderAngle1 - lastShoulderAngle).abs() <
        (shoulderAngle2 - lastShoulderAngle).abs()){
      print('shouulderAngle1=${shoulderAngle1}');
      print('shouulderAngle2=${shoulderAngle2}');
      shoulderAngle = shoulderAngle1;
      print('ang=${ang}');
      wristAngle = theta31+180-theta+ang-360;
    }
    else{
      print('shoulderAngle2=${shoulderAngle2}');
      print('shoulderAngle1=${shoulderAngle1}');
      shoulderAngle = shoulderAngle2;
      print('ang=${ang}');
      wristAngle = theta31+180-theta+ang-360;
    }
    if(wristAngle>180) wristAngle=wristAngle-360;
    if(wristAngle<-180) wristAngle=wristAngle+360;
    //theta3 = (180 - elbowAngle) / 2;
    //shoulderAngle = theta + theta3;


    // wristAngle = theta32+180-theta+ang;

  }
}




class MyHomePage extends StatefulWidget {
  final Socket channel;
  MyHomePage({Key key, this.title, this.channel}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>  {

  @override
  void initState()  {
    super.initState();
    if(WIFIConnect==false) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showDialog());
    }
    else{
      print('about to load GRBLSettings');
      loadGRBLSettings();
    }



  }

  int _counter = 0;
  double xJogSpeed=0;
  double yJogSpeed=0;
  double zJogSpeed=0;
  /*
  snapshot
  */
  Timer _timer;
  double xJogSpeedMax=600;
  double yJogSpeedMax=600;
  double zJogSpeedMax=600;
  double xPos=0;
  double yPos=0;
  double zPos=0;
  int GcodeTime=0;
  double leftJoyAng;
  double leftJoyDist;

  double shoulderPos=0;
  double elbowPos=0;
  double wristPos=0;
  double AshoulderPos=0;
  double AelbowPos=0;
  double AwristPos=0;
  double BshoulderPos=0;
  double BelbowPos=0;
  double BwristPos=0;
  double lastSangle;

  bool readyToSendFlag=true;
  bool readyToSendFlag2=true;
  bool timerCanceled=true;
  bool buttonBflag=false;
  bool buttonAflag=false;
  bool fwdFlag=false;
  double _currentSliderValue = 20;
  double _currentAccelSliderValue = 20;
  bool isButton1Pressed = false;
  bool isButton2Pressed = false;
  bool isButton3Pressed = false;
  bool isButton4Pressed = false;
  bool isPoint1Recorded = false;
  bool isPoint2Recorded = false;
  bool isPoint3Recorded = false;
  bool isPoint4Recorded = false;
  var quadraticCurve;
  var quadraticCurveZ;
  double curveFraction=0;

  var pointList = List.generate(4, (i) => List(3), growable: false); //creates 4 by 3 growable array
  int codeLine=0;
  bool jogMode=true;

  var mSpeed = MotorSpeed(359, -20, 359, -20, 90, 90, 50,600);
  var xyz=xYZPosition(0,-90);
  var J=0;
  int gridPoint=0;




  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Not Connected to ShotArm WIFI"),
          content: new Text("Connect your phone's WIFI to \"ShotArm\" \nand start the app again "),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(                   //was using flat button but has been depreciated
              child: new Text("OK"),
              onPressed: () {
                //Navigator.of(context).pop();
                exit(0);//close app

              },
            ),
          ],
        );
      },
    );
  }

  void loadGRBLSettings(){
    //https://github.com/bdring/Grbl_Esp32/wiki/Settings

    widget.channel.write(String.fromCharCode(36)+'11=9\n');
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'100=100\n');//steps/mm x axis
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'101=100\n');//steps/mm y axis
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'102=100\n');//steps/mm z axis
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'110=50000\n');
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'111=50000\n');
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'112=49999\n');
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'120=1000\n');
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'121=1000\n');
    sleep(const Duration(milliseconds: 200));//don't know if this is needed
    widget.channel.write(String.fromCharCode(36)+'122=1000\n');
    // sleep(const Duration(milliseconds: 200));//don't know if this is needed
    //widget.channel.write(String.fromCharCode(36)+'130=9600\n');
    // sleep(const Duration(milliseconds: 200));//don't know if this is needed
    // widget.channel.write(String.fromCharCode(36)+'131=6400\n');
    // sleep(const Duration(milliseconds: 200));//don't know if this is needed
    //widget.channel.write(String.fromCharCode(36)+'132=19200\n');


  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }



  JoystickDirectionCallback onDirectionChangedRight(
      double degrees, double distance) {
    String data =
        "${degrees.toStringAsFixed(2)},${distance.toStringAsFixed(2)}";
    print(data);
    // writeData(data);
  }


  JoystickDirectionCallback onDirectionChangedLeft(double degrees, double distance) {

    //print("start on direction changed left");
    //print("LeftDegree : ${degrees.toStringAsFixed(2)}");
    double degrees2;
    leftJoyAng=degrees;
    leftJoyDist=distance;
    if(360-leftJoyAng+90>=360) //converts joystick angle to arm coordinate system
      degrees2=360-leftJoyAng+90-360;
    else
      degrees2=360-leftJoyAng+90;

    xJogSpeed=leftJoyDist*xJogSpeedMax*cos(degrees2/360*2*pi);
    yJogSpeed=leftJoyDist*yJogSpeedMax*sin(degrees2/360*2*pi);
    if(readyToSendFlag2==true && readyToSendFlag==true) {
      widget.channel.write("?\n"); //send request for position to esp32
      readyToSendFlag2=false;
      print("onDirectionChangedLef-------sending ?");
    }
    //print("onDirectionChangedLef-------xJogSpeed=${xJogSpeed}");
    //print("onDirectionChangedLef-------_timer=${_timer}");
/*
    if (timerCanceled==true){// && (xJogSpeed!=0 || yJogSpeed!=0)) {
      print("onDirectionChangedLeft------Starting timer");
      _startTimer();
      timerCanceled=false;//
    }
 */
  }



  void _startTimer() {

    if (_timer != null) {
      //_timer.cancel();
    }
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        print('_startTimer--- xjogspeed=${xJogSpeed}');
        print('_startTimer--- Yjogspeed=${yJogSpeed}');

        if(xJogSpeed==0 && yJogSpeed==0 ) { //stop timer if joystick centred
          _timer.cancel();
          print("timer cancelled+++++++++++++++++++++++++++++++++++++++++++++++++");
          readyToSendFlag=true;
          readyToSendFlag2=true;
          timerCanceled=true;

          print('_startTimer--- stopping timer');
        }
        else
        if(readyToSendFlag==true) {
          widget.channel.write("?\n"); //send request for position to esp32
          print('_startTimer--- sending   ?');
          readyToSendFlag2=false;
        }
        if (_timer != null)
          print('_startTimer--- _timer=true');
        else
          print('_startTimer--- _timer=false');
      });
    });
  }


  void _sendGcode_line(){

    double sPeed;

    sPeed=sqrt(pow(xJogSpeed,2) + pow(yJogSpeed, 2));//resultant speed of end of arm
    print(DateTime.now().millisecondsSinceEpoch-GcodeTime);
    GcodeTime=DateTime.now().millisecondsSinceEpoch;

    mSpeed=MotorSpeed(xyz.x, xyz.y , xyz.x+xJogSpeed*1/600, xyz.y+yJogSpeed*1/600, 90, 90, 90,sPeed); //for timer spacing of 100ms
    print("_sendGcode_line xyz.x ${xyz.x.toStringAsFixed(4)} xyz.y=${xyz.y.toStringAsFixed(4)}");

    widget.channel.write("G1 X${mSpeed.shoulderAngle.toStringAsFixed(4)} Y${mSpeed.elbowAngle.toStringAsFixed(4)} F600\n");
    print('_sendGcode_line G1 X${mSpeed.shoulderAngle.toStringAsFixed(4)} Y${mSpeed.elbowAngle.toStringAsFixed(4)} F600  *************************');

    readyToSendFlag =false; //stops more data being sent before grbl has replied with "ok"
    print('_sendGcode_line readyToSendFlag=${readyToSendFlag}');
  }




  @override
  void dispose() {
    widget.channel.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.






    int gCodeLn=0;
    bool gCodeSendFlag=false;
    final gCode = [
      [11, 0, 0],
      [10, 10, 0],
      [20, 20, 0],
      [30, 10, 0],
      [30, 0, 0],
    ];






    void _sendXmovement(){
      //widget.channel.write("?\n"); //send request for position to esp32
      if(readyToSendFlag) {
        shoulderPos += 20;
        //widget.channel.write("G1 X${shoulderPos.toStringAsFixed(4)} Y${0} F600\n");
        widget.channel.write(String.fromCharCode(36)+"J= X0 F100000\n");
        print(String.fromCharCode(36)+"J= X5000 F100000\n");
        readyToSendFlag=false;
        print('_sendGcode_line G1 X${shoulderPos.toStringAsFixed(4)} Y${0} F600  *************************');
        print(DateTime.now().millisecondsSinceEpoch);
      }
    }


    void _sendGCodeSegment(double x, double y, double z){
      //widget.channel.write("?\n"); //send request for position to esp32
      if(readyToSendFlag) {
        //widget.channel.write("G1 X${shoulderPos.toStringAsFixed(4)} Y${0} F600\n");
        widget.channel.write('G1 X${x} Y${y} Z${z} F${_currentSliderValue*1000}\n');     // widget.channel.write('G1 X${x} Y${y} Z${z} F100000\n');
        print(String.fromCharCode(36)+'G1 X${x} Y${y} Z${z} F${_currentSliderValue*1000}\n');
        print(DateTime.now().millisecondsSinceEpoch);

        readyToSendFlag=false;

      }
    }
/*
    void straightLine() {
      int maxgCodeLn = 5;
      double gcx, gcy, gcz; //gcode x,y,z

      AshoulderPos=shoulderPos;
      AelbowPos=elbowPos;
      AwristPos=wristPos;


      if(jogMode==false) {  //i.e. play mode
        print('Straight line. Gcode line=${gCodeLn}');
        gcx = gCodeLn.toDouble() * 20;
        gcy = gCodeLn.toDouble() * 50;
        gcz = gCodeLn.toDouble() * 7;
        _sendGCodeSegment(gcx, gcy, gcz);
        gCodeLn++;
        if (gCodeLn >= maxgCodeLn) {
          jogMode = true;
          gCodeLn = 0;
        }
      }
      */




    void playPointsReverse() {
      _sendGCodeSegment(quadraticCurve.pointAt(curveFraction)[0],
          quadraticCurve.pointAt(curveFraction)[1], quadraticCurveZ.pointAt(curveFraction)[1]);

      if (curveFraction <= 0) {
        jogMode = true;
      }
      else
        curveFraction -= 0.025;
      print('curveFraction=${curveFraction}');
    }

    void playScanGrid2(){

      var scanGridList=[[-739,6279,-4431],
        [-743,4789,-3236],
        [-1429,4065,-2108],
        [-2636,4065,-1143],
        [-4045,4789,-594],
        [-5539,6279,-591],
        [-5543,4789,603],
        [-4048,3296,601],
        [-2183,2400,-173],
        [-217,2400,-1746],
        [751,3296,-3238],
        [754,4789,-4434],
        [2163,4065,-4983],
        [2616,2400,-4013],
        [1874,1051,-2340],
        [-2925,1051,1499],
        [-5017,2400,2093],
        [-6229,4065,1731],
        [-7436,4065,2696],
        [-6983,2400,3666],
        [-7725,1051,5339],
        [-12525,1051,-6180],
        [-14617,2400,-5586],
        [-15829,4065,-5948],
        [-15143,4789,-7076],
        [-13648,3296,-7078],
        [-11783,2400,7506],
        [-9817,2400,5933],
        [-8848,3296,4441],
        [-8845,4789,3245],
        [-10339,6279,3248],
        [-10343,4789,4443],
        [-11029,4065,5571],
        [-12236,4065,6536],
        [-13645,4789,7085],
        [-15139,6279,7088]];

      gridPoint=0;
      print("Playing scanGrid");
      widget.channel.write('G1 X${scanGridList[gridPoint][0] //go to first point
          .toDouble()} Y${scanGridList[gridPoint][1]
          .toDouble()} Z${scanGridList[gridPoint][2]
          .toDouble()} F${_currentSliderValue * 1000}\n');
      sleep(const Duration(seconds: 30)); //wait 30 seconds.

      for(gridPoint=1;gridPoint<=scanGridList.length;gridPoint++) { //go to remaining points
        widget.channel.write('G1 X${scanGridList[gridPoint][0]
            .toDouble()} Y${scanGridList[gridPoint][1]
            .toDouble()} Z${scanGridList[gridPoint][2]
            .toDouble()} F${_currentSliderValue * 1000}\n');
        sleep(const Duration(seconds: 5));
        widget.channel.write('M7\n'); //shutter release closed
        sleep(const Duration(milliseconds: 500));
        widget.channel.write('M9\n'); //shutter release open
      }

      jogMode = true;
      //print("Finished playing scanGrid");
    }



    void playScanGrid(){
      //var scanGridList = List.generate(10, (i) => List(3), growable: false); //creates 4 by 3 growable array
      var scanGridList=[[100.0,150.0,20.0],[1000.0,1500.0,70.0],[2000,0,2],[250,200,30.0]];




      print("Playing scanGrid");

      _sendGCodeSegment(scanGridList[gridPoint][0].toDouble(), scanGridList[gridPoint][1].toDouble(), scanGridList[gridPoint][2].toDouble());
      //sleep(const Duration(seconds: 5));//don't know if this is needed
      //M7 M9


      if (gridPoint>=scanGridList.length) {
        jogMode = true;
      }
      else gridPoint++;

      //print("Finished playing scanGrid");
    }


    void playPoints(){

      _sendGCodeSegment(quadraticCurve.pointAt(curveFraction)[0], quadraticCurve.pointAt(curveFraction)[1], quadraticCurveZ.pointAt(curveFraction)[1]);

      if (curveFraction >= 1) {
        jogMode = true;
      }
      else curveFraction+=0.025;
      print('curveFraction=${curveFraction}');



    }

    void calcCurve(){
      // bezier.dart supports both quadratic curves...
      int i;

      for(i=0;i<=3;i++)
      {
        print('${pointList[i][0]}, ${pointList[i][1]}, ${pointList[i][2]}');
      }



      quadraticCurve = new CubicBezier([
        new vec.Vector2(pointList[0][0], pointList[0][1]),  //vec prefix added to prevent confusion of "color" between material and vector maths libraries.
        new vec.Vector2(pointList[1][0], pointList[1][1]),
        new vec.Vector2(pointList[2][0], pointList[2][1]),
        new vec.Vector2(pointList[3][0], pointList[3][1])
      ]);

      quadraticCurveZ = new CubicBezier([
        new vec.Vector2(pointList[0][0], pointList[0][2]),  //vec prefix added to prevent confusion of "color" between material and vector maths libraries.
        new vec.Vector2(pointList[1][0], pointList[1][2]),
        new vec.Vector2(pointList[2][0], pointList[2][2]),
        new vec.Vector2(pointList[3][0], pointList[3][2])
      ]);


      print('computed point ***********************= ${quadraticCurve.pointAt(0.5)}');
      print(quadraticCurve.length);

    }


    void straightLine(double xAgrbl, double yAgrbl, double zAgrbl,double  xBgrbl, double yBgrbl,double zBgrbl) {  //xA, yA etc are the coordinates taken from          esp32 GRBL
      //create list/array of coordinates to be converted to gcode and sent to esp
      //int i;
      int maxgCodeLn = 50;//was 30
      double xi, yi, xiplus, yiplus, lastSangle;
      double xA, yA, xB, yB;
      double AshoulderAng;
      double AelbowAng ;
      double AwristAng;

      double BshoulderAng;
      double BelbowAng;
      double BwristAng;

      if(fwdFlag) {   // if playing A to B
        AshoulderAng = xAgrbl * 100 / 5333.333; //GRBL gcode coords to angle(deg)
        AelbowAng = yAgrbl * 100 / 5333.333;
        AwristAng = zAgrbl * 100 / 5333.333;
        //shoulder and elbow : 64 microsteps/step, 200 steps per rev, 75:1 worm gear ratio, 2:1 sprocket ratio: steps/deg=64x200x75x2/360=5333.333333
        // wrist : 64 microsteps/step, 200 steps per rev, 60:1 worm gear ratio, 2:1 sprocket ratio: steps/deg=64x200x60x2/360=4266.666666

        BshoulderAng = xBgrbl * 100 / 5333.333;
        BelbowAng = yBgrbl * 100 / 5333.333;
        BwristAng = zBgrbl * 100 / 5333.333;
      }
      else{ // if playing B to A
        AshoulderAng = xBgrbl * 100 / 5333.333; //GRBL gcode coords to angle(deg)
        AelbowAng = yBgrbl * 100 / 5333.333;
        AwristAng = zBgrbl * 100 / 5333.333;
        // 64 microsteps/step, 200 steps per rev, 75:1 worm gear ratio, 2:1 sprocket ratio: steps/deg=64x200x75x2/360=5333.333333
        //5333.333x16/14=6095.23 steps/degree if using 14 tooth sprocket instead of 16 tooth.

        BshoulderAng = xAgrbl * 100 / 5333.333;
        BelbowAng = yAgrbl * 100 / 5333.333;
        BwristAng = zAgrbl * 100 / 5333.333;
      }

      if(jogMode==false) {  //i.e. play mode
        if(gCodeLn==0) {
          print(
              'A position in degrees= ${AshoulderAng},${AelbowAng},${AwristAng},${gCodeLn}');
          print(
              'B Position in degrees= ${BshoulderAng},${BelbowAng},${BwristAng}');
          print(
              'A position in GRBL mm = ${xAgrbl},${yAgrbl},${zAgrbl}');
          print(
              'B position in GRBL mm = ${xBgrbl},${yBgrbl},${zBgrbl}');
        }
        var Axyz = new xYZPosition(AshoulderAng, AelbowAng);
        xA=Axyz.x;
        yA=Axyz.y;
        //print('${xA},${yA},${i}');

        var Bxyz = new xYZPosition(BshoulderAng, BelbowAng);
        xB=Bxyz.x;
        yB=Bxyz.y;
        //print('B shoulder and elbow pos=${BshoulderAng},${BelbowAng}***********');
        if(gCodeLn==0) {
          print(
              'A position in x,y (mm)= ${xA},${yA}');
          print(
              'B position in x,y (mm)= ${xB},${yB}');

        }

        //print('${xA},${xB}');

        // var xyz = new xYZPosition(45,56);

        //MotorSpeed(xi, yi, xiplus, yiplus, 180, 180,600);
        lastSangle =AshoulderAng;


        xi = xA + (xB - xA) / maxgCodeLn * gCodeLn;
        yi = yA + (yB - yA) / maxgCodeLn * gCodeLn;
        xiplus = xA + (xB - xA) / maxgCodeLn * (gCodeLn + 1);
        yiplus = yA + (yB - yA) / maxgCodeLn * (gCodeLn + 1);


        var mSpeed =new MotorSpeed(xi, yi, xiplus, yiplus, AwristAng, BwristAng, lastSangle,600);

        //var mSpeed =new MotorSpeed(-100, 5, 100, -5, 180, 180, 45,600);


        print('${gCodeLn}, straightLine------GRBL (mm), ${mSpeed.shoulder_mm}, ${mSpeed.elbow_mm}, ${mSpeed.wrist_mm}, x and y (mm), ${xi},${yi}, xA yA xB yB ${xA},${yA},${xB},${yB}');
        //print('${i}, ${xi}, ${yi}, ${xiplus}, ${yiplus}');
        lastSangle = mSpeed.sAng2;
        //lastEangle =52;

        //_sendGCodeSegment(mSpeed.sAng2, mSpeed.eAng2, mSpeed.wAng2);
        _sendGCodeSegment(mSpeed.shoulder_mm, mSpeed.elbow_mm, mSpeed.wrist_mm);

        gCodeLn++;
        if (gCodeLn >= maxgCodeLn) {
          jogMode = true;
          gCodeLn = 0;
        }

      }
    }





    int decodeSnapshot(String sShot){
      if(sShot.contains('ok') && sShot.contains('MPos')==false ) {
        print(('ok +++++++'));
        print(DateTime.now().millisecondsSinceEpoch);
        return 1;
      }
      if(sShot.contains('MPos')){  //was WPos for some reason
        shoulderPos = double.parse(sShot.split(":")[1].split(",")[0]);

        elbowPos = double.parse(sShot.split(":")[1].split(",")[1]);
        // print('decodeSnapshot--- elbowPos= ${elbowPos}');

        wristPos = double.parse(sShot.split("|")[1].split(",")[2]);

        print("Decode snapshot: isPoint1Recorded=${isPoint1Recorded}, isButton1Pressed=${isButton1Pressed}");
        if(isPoint1Recorded && isButton1Pressed){
          pointList[0][0]=shoulderPos;
          pointList[0][1]=elbowPos;
          pointList[0][2]=wristPos;
          isPoint1Recorded=false;

          print('Decode snapshot: 1 position=${shoulderPos}, ${elbowPos}, ${wristPos}');
          /*
          AshoulderPos=shoulderPos;
          AelbowPos=elbowPos;
          AwristPos=wristPos;
          */
          //pointList.add([shoulderPos,elbowPos,wristPos]);


          //buttonAflag=false;
        }
        if(isPoint2Recorded && isButton2Pressed){
          pointList[1][0]=shoulderPos;
          pointList[1][1]=elbowPos;
          pointList[1][2]=wristPos;
          isPoint2Recorded=false;
          print('Decode snapshot: 2 position=${pointList[1][0]}, ${pointList[1][1]}, ${pointList[1][2]}');
        }
        if(isPoint3Recorded && isButton3Pressed){
          pointList[2][0]=shoulderPos;
          pointList[2][1]=elbowPos;
          pointList[2][2]=wristPos;
          isPoint3Recorded=false;
          print('Decode snapshot: 3 position=${shoulderPos}, ${elbowPos}, ${wristPos}');
        }

        if(isPoint4Recorded && isButton4Pressed){
          pointList[3][0]=shoulderPos;
          pointList[3][1]=elbowPos;
          pointList[3][2]=wristPos;
          isPoint4Recorded=false;
          print('Decode snapshot: 4 position=${shoulderPos}, ${elbowPos}, ${wristPos}');
        }






        if(buttonBflag){
          BshoulderPos=shoulderPos;
          BelbowPos=elbowPos;
          BwristPos=wristPos;
          print('Decode snapshot: B position=${BshoulderPos}, ${BelbowPos}, ${BwristPos}');
          buttonBflag=false;
        }

        //print('decodeSnapshot--- wristPos= ${wristPos}');
        xyz=xYZPosition(shoulderPos, elbowPos);
        print('decodeSnapshot--- GRBL Pos= ${shoulderPos},${elbowPos},${wristPos}');
        //print('decodeSnapshot--- decodeSnapshot xy position (mm) ${xyz.x},${xyz.y}');
        return 2;
      }
      else
        return 3;// contains neither ok nor MPos
    }


    return Scaffold(

      // loadGRBLSettings();
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(25.0), // here the desired height
          child: AppBar(title: Text("ShotArm Control"),
            // ...
          )
      ),

      body:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: <Widget>[

              Row(
                  children: <Widget>[

                    //     onLongPressUp: _stopRec, // stop recording when released
                    GestureDetector(

                      onLongPress: (){
                        jogMode=true;
                        //widget.channel.write(String.fromCharCode(36)+"J= X-100000 F100000\n"); // start jog when long pressed
                        widget.channel.write(String.fromCharCode(36)+"J= X-9600 F100000\n"); // start jog when long pressed
                      },
                      onLongPressUp:(){
                        widget.channel.write(String.fromCharCode(133));// cancel jog when long press released
                        print("long press up");
                        //sleep(const Duration(microseconds: 10));//don't know if this is needed
                        sleep(const Duration(milliseconds: 200));//don't know if this is needed
                        widget.channel.write("?");
                        //double jogShoulderPos=shoulderPos+0;
                        //widget.channel.write(String.fromCharCode(36)+"J= X" + jogShoulderPos.toString() +" F100000\n");

                      },
                      child:RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(80, 80)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        //child:Text('X Left'),
                        padding: EdgeInsets.all(20.0),
                        shape: CircleBorder(),
                        child: Image.asset('assets/images/ArrowCWx.png'),
                        //assets:
                        //      - assets/images/
                      ),
                    ),

                    GestureDetector(
                      onLongPress: (){
                        jogMode=true;
                        widget.channel.write(String.fromCharCode(36)+"J= X9600 F100000\n"); // start jog when long pressed
                      },
                      onLongPressUp:(){
                        widget.channel.write(String.fromCharCode(133));// cancel jog when long press released
                        print("long press up");
                        sleep(const Duration(milliseconds: 200));//don't know if this is needed
                        widget.channel.write("?");
                        //double jogShoulderPos=shoulderPos+0;
                        //widget.channel.write(String.fromCharCode(36)+"J= X" + jogShoulderPos.toString() +" F100000\n");

                      },
                      child:RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(80, 80)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        //child:Text('X Right'),
                        child: Image.asset('assets/images/ArrowCCWx.png'),
                        padding: EdgeInsets.all(20.0),
                        shape: CircleBorder(),
                      ),
                    ),
                  ]

              ),

              Row(
                  children: <Widget>[

                    GestureDetector(
                      onLongPress: (){
                        jogMode=true;
                        widget.channel.write(String.fromCharCode(36)+"J= Y-6400 F100000\n"); // start jog when long pressed
                      },
                      onLongPressUp:(){
                        widget.channel.write(String.fromCharCode(133));// cancel jog when long press released
                        print("long press up");
                        sleep(const Duration(milliseconds: 200));//don't know if this is needed
                        widget.channel.write("?");
                        //double jogShoulderPos=shoulderPos+0;
                        //widget.channel.write(String.fromCharCode(36)+"J= X" + jogShoulderPos.toString() +" F100000\n");

                      },
                      child:RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(80, 80)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        //child:Text('Y Left'),
                        child: Image.asset('assets/images/ArrowCWy.png'),
                        padding: EdgeInsets.all(20.0),
                        shape: CircleBorder(),
                      ),
                    ),

                    GestureDetector(
                      onLongPress: (){
                        jogMode=true;
                        widget.channel.write(String.fromCharCode(36)+"J= Y6400 F100000\n"); // start jog when long pressed
                      },
                      onLongPressUp:(){
                        widget.channel.write(String.fromCharCode(133));// cancel jog when long press released
                        print("long press up");
                        sleep(const Duration(milliseconds: 200));//don't know if this is needed
                        widget.channel.write("?");
                        //double jogShoulderPos=shoulderPos+0;
                        //widget.channel.write(String.fromCharCode(36)+"J= X" + jogShoulderPos.toString() +" F100000\n");

                      },
                      child:RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(80, 80)),

                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        //child:Text('Y Right'),
                        child: Image.asset('assets/images/ArrowCCWy.png'),
                        padding: EdgeInsets.all(20.0),
                        shape: CircleBorder(),
                      ),
                    ),
                  ]

              ),


              Row(
                children: <Widget>[

                  Slider(   //speed
                    value: _currentSliderValue,
                    min: 5,
                    max: 100,
                    divisions: 20,

                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                  Text('Play Speed'),

                ],
              ),



              Row(
                children: <Widget>[
                  Slider(   //acceleration
                    value: _currentAccelSliderValue,
                    min: 5,
                    max: 100,
                    divisions: 20,
                    label: _currentAccelSliderValue.round().toString(),
                    onChangeEnd:  (double value) {
                      setState(() {
                        print(String.fromCharCode(36)+'120=' + (10*_currentAccelSliderValue).round().toString()+'\n');
                        widget.channel.write(String.fromCharCode(36)+'120=' + (10*_currentAccelSliderValue).round().toString()+'\n' + String.fromCharCode(36)+'121=' + (10*_currentAccelSliderValue).round().toString()+'\n');
                      });
                    },
                    onChanged: (double value) {
                      setState(() {
                        _currentAccelSliderValue = value;
                        //print('gggggggggggggggggggggggggggggggggggggggggggggggggggggggg');
                        //print(String.fromCharCode(36)+'120=' + (10*_currentAccelSliderValue).round().toString());


                        //sleep(const Duration(milliseconds: 100));//don't know if this is needed
                      });
                    },
                  ),
                  Text('Acceleration'),


                ],
              ),



              StreamBuilder(
                stream: widget.channel,
                builder: (context, snapshot) {
                  int snpRes;
                  if(snapshot.hasData){
                    print('StreamBuilder--- Snapshot data= ${String.fromCharCodes(snapshot.data)}');
                    //print(snapshot.data);
                    // print("StreamBuilder--- ready to send flag at entry= ${readyToSendFlag}");
                    //  print("StreamBuilder--- jogMode= ${jogMode}");
                    if (jogMode) { //jog mode
                      snpRes =decodeSnapshot(String.fromCharCodes(snapshot.data));  //run decodeSnapshot
                      print("snpRes=${snpRes}");
                      if (snpRes == 1) { //and if "ok" has been received then set readyToSendFlag to true
                        readyToSendFlag = true;
                        print("StreamBuilder---OK received");
                        //straightLine(AshoulderPos,AelbowPos,AwristPos,BshoulderPos,BelbowPos,BwristPos);
                      }
                      if (snpRes == 2 && readyToSendFlag==true) { //if "mpos" line is received
                        readyToSendFlag2 = true;
                        print("StreamBuilder---mpos received");
                        //_sendGcode_line(); // send gcode line
                      }
                    }
                    else{ //play mode
                      snpRes =decodeSnapshot(String.fromCharCodes(snapshot.data));  //run decodeSnapshot
                      if (snpRes == 1) { //and if "ok" has been received then set readyToSendFlag to true
                        readyToSendFlag = true;
                        //straightLine(AshoulderPos,AelbowPos,AwristPos,BshoulderPos,BelbowPos,BwristPos);
                        if(fwdFlag)
                          playPoints();
                        //playScanGrid();
                        else
                          playPointsReverse();
                      }
                    }
                    print("StreamBuilder--- ready to send flag at exit = ${readyToSendFlag}");
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //child: Text(snapshot.hasData ? '$snapshot.data': ''),


                  );
                },
              ),


            ],
          ),
          /*
            Container(
            padding: EdgeInsets.all(100),
            color:Colors.cyan,
          ),
*/
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[



              RawMaterialButton(
                fillColor: isButton1Pressed ? Colors.green : Colors.blueGrey,
                elevation: 2.0,
                child:Text('1',style: new TextStyle(
                    fontSize: 20.0)),
                padding: EdgeInsets.all(20.0),
                shape: CircleBorder(),
                onPressed: () {

                  //_showDialog();

                  /*
                  widget.channel.write("?");
                  buttonBflag=true;
                 */
                  setState(() {
                    isButton1Pressed =!isButton1Pressed;
                  });
                  isPoint1Recorded=true;
                  //widget.channel.write(String.fromCharCode(36)+'11=9\n');
                  //widget.channel.write(String.fromCharCode(36)+'120=' + (111).round().toString()+'\n');
                  print(String.fromCharCode(36)+'11=9');
                  print("Button 1: isPoint1Recorded=${isPoint1Recorded}, isButton1Pressed=${isButton1Pressed}");
                  //if(isButton1Pressed) widget.channel.write("?");

                },

              ),
              RawMaterialButton(
                fillColor: isButton2Pressed ? Colors.green : Colors.blueGrey,
                elevation: 2.0,
                child:Text('2',style: new TextStyle(
                    fontSize: 20.0)),
                padding: EdgeInsets.all(20.0),
                shape: CircleBorder(),
                onPressed: () {
                  /*
                  widget.channel.write("?");
                  buttonBflag=true;
                 */
                  setState(() {
                    isButton2Pressed =!isButton2Pressed;
                  });
                  isPoint2Recorded=true;
                  //if(isButton2Pressed) widget.channel.write("?");

                },

              ),
              RawMaterialButton(
                fillColor: isButton3Pressed ? Colors.green : Colors.blueGrey,
                elevation: 2.0,
                child:Text('3',style: new TextStyle(
                    fontSize: 20.0)),
                padding: EdgeInsets.all(20.0),
                shape: CircleBorder(),
                onPressed: () {
                  /*
                  widget.channel.write("?");
                  buttonBflag=true;
                 */
                  setState(() {
                    isButton3Pressed =!isButton3Pressed;
                  });
                  isPoint3Recorded=true;
                  //if(isButton3Pressed) widget.channel.write("?");

                },

              ),
              RawMaterialButton(
                fillColor: isButton4Pressed ? Colors.green : Colors.blueGrey,
                elevation: 2.0,
                child:Text('4',
                    style: new TextStyle(
                        fontSize: 20.0)
                ),

                padding: EdgeInsets.all(20.0),
                shape: CircleBorder(),
                onPressed: () {
                  /*
                  widget.channel.write("?");
                  buttonBflag=true;
                 */
                  setState(() {
                    isButton4Pressed =!isButton4Pressed;
                  });
                  isPoint4Recorded=true;
                  //if(isButton4Pressed) widget.channel.write("?");

                },
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[


              Row(
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: () {
                        if(isButton1Pressed && isButton2Pressed && isButton3Pressed && isButton4Pressed) {
                          print(
                              'Play Button A-B: GRBL A and B positions ${AshoulderPos},${AelbowPos},${AwristPos}},${BshoulderPos},${BelbowPos},${BwristPos}');
                          jogMode = false;
                          readyToSendFlag = true;
                          fwdFlag = true;
                          gCodeLn = 0;
                          codeLine = 0;
                          gridPoint=0;
                          //straightLine(AshoulderPos,AelbowPos,AwristPos,BshoulderPos,BelbowPos,BwristPos);
                          calcCurve();
                          curveFraction=0;
                          playPoints();
                          //playScanGrid2();  //calcCurve(); , jogMode = false; and playPoints(); in stream builder also commented out
                        }
                      },
                      constraints: BoxConstraints.tight(Size(80, 80)),
                      elevation: 2.0,
                      fillColor: Colors.blueGrey,
                      child:Text('Play 1,2,3,4',
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                          fontSize: 15.0,


                        ),
                      ),


                      padding: EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        print("play pressed B-A");
                        jogMode=false;
                        print("1");
                        readyToSendFlag=true;
                        print("2");
                        //straightLine(AshoulderPos,AelbowPos,AwristPos,BshoulderPos,BelbowPos,BwristPos);
                        fwdFlag=false;
                        print("3");
                        gCodeLn=0;
                        print("4");
                        //straightLine(AshoulderPos,AelbowPos,AwristPos,BshoulderPos,BelbowPos,BwristPos);
                        calcCurve();
                        print("5");
                        curveFraction=1;
                        print("6");
                        playPointsReverse();
                        print("7");
                      },
                      constraints: BoxConstraints.tight(Size(80, 80)),
                      elevation: 2.0,
                      fillColor: Colors.blueGrey,
                      child:Text('Play 4,3,2,1',textAlign: TextAlign.center),

                      padding: EdgeInsets.all(10.0),
                      shape: CircleBorder(),
                    ),
                  ]
              ),
              Row(
                  children: <Widget>[

                    RawMaterialButton(
                      onPressed: () {
                        widget.channel.write("G10 P1 L20 X0 Y0 Z0\n");  //"G10 P1 L20 X Y Z0" zeros wpos (g54) coordinate system  https://github.com/gnea/grbl/issues/225
                        print("Home pressed");
                      },
                      constraints: BoxConstraints.tight(Size(80, 80)),
                      elevation: 2.0,

                      fillColor: Colors.blueGrey,
                      child:Text('Home'),
//$10=2 sets status report to return "wpos:" only when "?" is sent

                      padding: EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                    ),

                  ]
              ),

              Row(
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: (){
                        jogMode=true;
                        widget.channel.write(String.fromCharCode(36)+"J= Z-19200 F100000\n"); // start jog when long pressed
                      },
                      onLongPressUp:(){
                        widget.channel.write(String.fromCharCode(133));// cancel jog when long press released
                        print("long press up");
                        sleep(const Duration(milliseconds: 200));//don't know if this is needed
                        widget.channel.write("?");
                        //double jogShoulderPos=shoulderPos+0;
                        //widget.channel.write(String.fromCharCode(36)+"J= X" + jogShoulderPos.toString() +" F100000\n");

                      },
                      child:RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(80, 80)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        //child:Text('Z Left'),
                        child: Image.asset('assets/images/ArrowCWz.png'),
                        padding: EdgeInsets.all(20.0),
                        shape: CircleBorder(),
                      ),
                    ),

                    GestureDetector(
                      onLongPress: (){
                        jogMode=true;
                        widget.channel.write(String.fromCharCode(36)+"J= Z19200 F100000\n"); // start jog when long pressed
                      },
                      onLongPressUp:(){
                        widget.channel.write(String.fromCharCode(133));// cancel jog when long press released
                        print("long press up");
                        sleep(const Duration(milliseconds: 200));//don't know if this is needed
                        widget.channel.write("?");
                        //double jogShoulderPos=shoulderPos+0;
                        //widget.channel.write(String.fromCharCode(36)+"J= X" + jogShoulderPos.toString() +" F100000\n");

                      },
                      child:RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(80, 80)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        //child:Text('Z Left'),
                        child: Image.asset('assets/images/ArrowCCWz.png'),
                        padding: EdgeInsets.all(20.0),
                        shape: CircleBorder(),
                      ),
                    ),
                  ]

              ),
            ],
          ),
        ],
      ),

    );
  }
}
