import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/customer_profile/customer_profile.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:zipcular/repository/store/auth_view/profile/profile_bloc.dart';
import 'package:zipcular/repository/store/auth_view/profile/profile_event.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';

class ProfileBranch extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => ProfileBranch());
  }

  @override
  State<ProfileBranch> createState() => _ProfileBranchState();
}

class _ProfileBranchState extends State<ProfileBranch> {
  bool isLogin = false;
  UserRepository _userRepository = UserRepository();

  CustomerModel customer = CustomerModel.empty();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocProvider(
        create: (context) {
          return ProfileBloc(
            authenticationRepository:
                RepositoryProvider.of<AuthenticationRepository>(context),
          );
        },
        child: FutureBuilder<CustomerModel>(
          initialData: CustomerModel.empty(),
          future: requestCustomerProfile,
          builder:
              (BuildContext context, AsyncSnapshot<CustomerModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              // If there is an error, display an error message.
              return Center(
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
                        context.read<ProfileBloc>().add(ProfileSubmitted());
                      },
                      child: Text('Retry',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else {
              // Once data is loaded, display it.
              return CustomerProfile(
                routing: true,
                customer: snapshot.data!,
                callback: (data) async {
                  await _userRepository.deleteToken('from_branch_referal');
                  context.read<ProfileBloc>().add(ProfileSubmitted());
                },
              );
            }
          },
        ),
      ),
    );
  }

  final Future<CustomerModel> requestCustomerProfile =
      Future<CustomerModel>.delayed(
    const Duration(seconds: 0),
    () async {
      CustomerModel customer = CustomerModel.empty();

      UserRepository _userRepository = UserRepository();
      final fromBranchReferal =
          await _userRepository.readKey('from_branch_referal');
      ResponseService response =
          await ListingFacade().getCustomerProfile(fromBranchReferal);
      if (response.bSuccess!) {
        customer = response.data;
      }
      return customer;
    },
  );
}
