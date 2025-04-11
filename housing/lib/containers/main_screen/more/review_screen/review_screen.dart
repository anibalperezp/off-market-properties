import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:zipcular/commons/main.constants.global.dart';

import '../../../../repository/services/prod/common.service.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<double>? _scaleAnimation;
  double _rating = 1;
  String comment = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller!);
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller!);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller!.forward();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        toolbarHeight: 45,
        title: Text("Review"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rate Your Experience",
                    style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(
                  height: 25.0,
                ),
                Image.asset(
                  'assets/images/feedback.png',
                  height: 185,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 46.0),
                GFRating(
                  value: _rating,
                  borderColor: Colors.grey[600],
                  color: Colors.amber,
                  size: 40,
                  onChanged: (value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                ),
                SizedBox(height: 26.0),
                AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) => Opacity(
                    opacity: _opacityAnimation!.value,
                    child: Transform.scale(
                      scale: _scaleAnimation!.value,
                      child: child,
                    ),
                  ),
                  child: TextField(
                    maxLines: 9,
                    minLines: 1,
                    onChanged: (value) {
                      setState(() {
                        comment = value;
                      });
                    },
                    decoration: InputDecoration(
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      labelText: "Leave a comment",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) => Opacity(
                    opacity: _opacityAnimation!.value,
                    child: Transform.scale(
                      scale: _scaleAnimation!.value,
                      child: child,
                    ),
                  ),
                  child: OutlinedButton(
                    child: loading == false
                        ? Text("Submit",
                            style:
                                TextStyle(color: buttonsColor, fontSize: 16.0))
                        : Container(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    buttonsColor))),
                    onPressed: () async {
                      bool result = await submitReview();
                      Navigator.pop(context, result);
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }

  submitReview() async {
    bool result = false;
    setState(() {
      loading = true;
    });
    CommonService _commonService = new CommonService();
    var response = await _commonService.postReview(_rating.toInt(), comment);
    if (response.requiredRefreshToken) {
      response = await _commonService.postReview(_rating.toInt(), comment);
    }
    if (response.data!) {
      result = true;
    } else {
      setState(() {
        loading = false;
      });
    }
    return result;
  }
}
