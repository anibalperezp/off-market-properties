import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/store/no_connection/no_connection_bloc.dart';
import 'package:zipcular/repository/store/no_connection/no_connection_event.dart';
import 'package:zipcular/repository/store/no_connection/no_connection_state.dart';

class NoConnectionPartial extends StatelessWidget {
  NoConnectionPartial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoConnectionBloc, NoConnectionState>(
        listener: (context, state) {},
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.signal_wifi_off, size: 110, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Internet Connection',
                  style: TextStyle(fontSize: 24, color: buttonsColor),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 32),
                    backgroundColor: headerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  onPressed: () {
                    context
                        .read<NoConnectionBloc>()
                        .add(NoConnectionSubmitted());
                  },
                  child: Text('Retry',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ));
  }
}
