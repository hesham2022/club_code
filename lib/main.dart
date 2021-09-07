import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final _lightBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
        BorderSide(color: Colors.grey, style: BorderStyle.solid, width: 2));

class _MyHomePageState extends State<MyHomePage> {
  String code = '';
  String name = '';
  Data? data;
  Widget _textField() => TextField(
        onChanged: (v) {
          code = v;
        },
        decoration: InputDecoration(
          border: _lightBorder,
          enabledBorder: _lightBorder,
          focusedBorder: _lightBorder,
        ),
      );
  @override
  void initState() {
    getFromStorage().then((value) {
      data = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (ctx) => TextButton(
            onPressed: () async {
              _modalBottomSheetMenu(
                  ctx,
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        _textField(),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          child: Text('send'),
                          onPressed: () async {
                            try {
                              data = await x(code);
                              await setData(jsonEncode(data));
                              setState(() {});
                              Navigator.pop(context);
                            } catch (e) {
                              Navigator.pop(context);
                              showCupertinoDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) => AlertDialog(
                                        title: Text("خطأ"),
                                        content: Text("الكود خطأ"),
                                      ));
                            }
                          },
                        )
                      ],
                    ),
                  ));
            },
            child: Text(
              'ادخل الكود',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: data == null
              ? Center(
                  child: Text('لا توجد بيانات '),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    data!.name.isEmpty
                        ? Text(' غير مسجل')
                        : Text('الاسم: ${data!.name}'),
                    SizedBox(
                      height: 30,
                    ),
                    Text('تاريخ الانتهاء: ${data!.expired}'),
                    SizedBox(
                      height: 30,
                    ),
                    Text('الاكاديميه: ${data!.academy}'),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text('المنطقه: ${data!.area}'),
                    SizedBox(
                      height: 30,
                    ),
                    Image.network(
                      'https://ticket.alqadsiah.com.sa${(data!.image as String).replaceFirst('.', '')}',
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

void _modalBottomSheetMenu(context, widget) {
  showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: 350.0,
          color: Colors.transparent, //could change this to Color(0xFF737373),
          //so you don't have to change MaterialApp canvasColor
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: new Center(
                child: widget,
              )),
        );
      });
}

Future<String?> getData(String code) async {
  final dio = Dio();
  try {
    final response = await dio
        .get('https://ticket.alqadsiah.com.sa/api.php?do=QR&essa_app=$code');
    // print(getPrettyJSONString((response.data as String).split('<hr />')));

    return response.data as String;
  } catch (e) {
    print(e);
  }
}

Future<Data> x(String code) async {
  final Map<String, dynamic> map = {};
  var json = await getData(code);
  // ('''"{"EXPIRED":"2021\/10\/05","ACADEMY":"<img src=https:\/\/ticket.alqadsiah.com.sa\/data\/images\/img-a91d1888b57840dfe62a9c235f79ed8c.png style=\"max-width:48px;max-height:48px;\" \/><br \/>أكاديميات الجودو و تنس طاولة<br \/> أكاديميات الجودو و التنس طاولة","AREA":"أكاديميات الجودو و تنس طاولة","DAYS":"حسب الاختيار","IMAGE":"<img src=.\/cache\/qrcode_16307965021FA0469B_8B65A4D9.png \/>","NAME":"عيسى علي"}<hr />{"EXPIRED":"2021\/10\/05","ACADEMY":"<img src=https:\/\/ticket.alqadsiah.com.sa\/data\/images\/img-784005fce1a5ad4a134709126ed8a299.png style=\"max-width:48px;max-height:48px;\" \/><br \/>أكاديميات السباحة<br \/> أكاديميات القادسية بالعقربية","AREA":"مسبح نادي القادسية","DAYS":"سبت - اثنين - اربعاء<br \/>\r\nSaturday - Monday - Wednesday","IMAGE":"<img src=.\/cache\/qrcode_163079650212752767_42FE00D8.png \/>","NAME":""}<hr />''')
  //     .removeAllHtmlTags('');
// final decodedJson = jsonDecode(jsonDecode(json));
  final first = (json!.replaceAll(r'\', ''))
      .removeAllHtmlTags('')
      .replaceAll('\"{"', "\"{")
      //  .replaceAll('}{', '},{')
      .replaceAll('{', '')
      .replaceAll('}', '')
      .replaceAll('{}', '')
      .replaceAll('\""', "\"");

  //print(jsonDecode(first));
  // print(jsonDecode(first));
  first.split(',').forEach((e) {
    final newList = (e.split(':'));
    final fL = newList[0].replaceAll('\"', '');
    final sL = newList[1].replaceAll('\"', '');
    final Map<String, dynamic> newMAP = {fL: sL};
    map.addAll(newMAP);
    //print(jsonDecode('{' + e + '}'));
  });
  print(map);
  return (Data.fromJson(map));

// final academy = json;

// final htmlDocument = parse(json);

//   print(htmlDocument);
}

extension RemoveHtm on String {
  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return this.replaceAll(exp, '');
  }
}

String getPrettyJSONString(jsonObject) {
  var encoder = new JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));

String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    required this.expired,
    required this.academy,
    required this.area,
    required this.days,
    required this.image,
    required this.name,
  });

  String expired;
  String academy;
  String area;
  String days;
  String image;
  String name;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        expired: json["EXPIRED"],
        academy: json["ACADEMY"],
        area: json["AREA"],
        days: json["DAYS"],
        image: json["IMAGE"],
        name: json["NAME"],
      );

  Map<String, dynamic> toJson() => {
        "EXPIRED": expired,
        "ACADEMY": academy,
        "AREA": area,
        "DAYS": days,
        "IMAGE": image,
        "NAME": name,
      };
}

Future<void> setData(String data) async {
  final instance = await SharedPreferences.getInstance();
  await instance.setString('data', data);
}

Future<Data> getFromStorage() async {
  final instance = await SharedPreferences.getInstance();
  final s = await instance.getString('data');
  return Data.fromJson(jsonDecode(s!));
}
