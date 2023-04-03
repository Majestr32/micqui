import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:micqui/core/constants/colors.dart';
import 'package:micqui/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:micqui/features/profile/presentation/edit_profile/widgets/date_picker.dart';
import 'package:micqui/features/profile/presentation/edit_profile/widgets/image_picker/profile_Image_picker.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/themes/theme.dart';
import 'package:date_format/date_format.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../data/models/user/user_model.dart';
import '../../../../data/repositories/firestore_repository.dart';
import '../../../../data/repositories/storage_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../home/home.dart';
import 'bloc/create_profile_bloc.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  late final CreateProfileBloc _bloc = CreateProfileBloc(
    firestore: FirestoreRepository(firestore: FirebaseFirestore.instance),
    storage: StorageRepository(storage: FirebaseStorage.instance),
    authBloc: context.read<AuthBloc>(),
  );
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  final _nickNameController = TextEditingController();
  final _nameController = TextEditingController();

  final _dateController = TextEditingController();

  late int age;

  late String? selectedCountry;
  late FocusNode _focusNode;

  // late UserModel user;

  @override
  void initState() {
    // user = BlocProvider.of<ProfileBloc>(context).state.user!;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _nickNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: BlocConsumer<CreateProfileBloc, CreateProfileState>(
        bloc: _bloc,
        listener: (context, state) {
          state.maybeMap(
              success: (_) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Home(),
                    ),
                  ),
              error: (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.accent,
                    duration: const Duration(seconds: 5),
                    content: Text(
                      e.error,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              orElse: () {});
        },
        builder: (context, state) {
          return state.maybeMap(
            loading: (_) => const LoadingIndicator(),
            orElse: () => SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 127,
                        left: 0,
                        child: Transform.rotate(
                          alignment: Alignment.topLeft,
                          angle: pi / 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: 97,
                            height: 158,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8),
                          child: Transform.rotate(
                            alignment: Alignment.topRight,
                            angle: pi / -5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              width: 130,
                              height: 244,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 36),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      _formKey.currentState!.save();

                                      _bloc.add(CreateProfileEvent.createFields(
                                        file: state.image,
                                        image: '',
                                        fullName: _nameController.text,
                                        country: selectedCountry!,
                                        dateOfBirth: _dateController.text,
                                        nickName: _nickNameController.text,
                                      ));
                                    },
                                    child: const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.check,
                                          color: AppColors.lightGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 138,
                              width: 138,
                              child: ProfileImagePicker(
                                userImage: (file) {
                                  _bloc.add(
                                      CreateProfileEvent.getImage(image: file));
                                },
                                avatar: const SizedBox(),
                                user: UserModel(),
                              ),
                            ),
                            const Flexible(
                              child: SizedBox(
                                height: 83,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        AppText.additionalInfo,
                                        style: TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      const Text(
                                        AppText.surveyOrganizers,
                                        style: TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          AppText.fullName,
                                          style: TextStyle(
                                              color: AppColors.text,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ),
                                      Material(
                                        child: TextFormField(
                                          controller: _nameController,
                                          style: AppTheme
                                              .themeData.textTheme.labelSmall!
                                              .copyWith(fontSize: 14),
                                          decoration: const InputDecoration(
                                            prefix: SizedBox(
                                              width: 6,
                                            ),
                                            contentPadding: EdgeInsets.only(
                                                bottom: 1, left: 5),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Field cant be empty';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          AppText.country,
                                          style: TextStyle(
                                              color: AppColors.text,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ),
                                      DropdownButtonFormField<String>(
                                        style: AppTheme
                                            .themeData.textTheme.labelSmall!
                                            .copyWith(fontSize: 14),
                                        // value: selectedCountry,
                                        iconSize: 15,
                                        decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 5),
                                            border: OutlineInputBorder()),
                                        icon: const FaIcon(
                                            FontAwesomeIcons.chevronDown),
                                        items: AppText.countries
                                            .map(
                                              (country) =>
                                                  DropdownMenuItem<String>(
                                                value: country,
                                                child: Text(
                                                  country,
                                                  style: AppTheme.themeData
                                                      .textTheme.labelSmall!
                                                      .copyWith(fontSize: 14),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (country) {
                                          selectedCountry = country;
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Field cant be empty';
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          AppText.dateOfBirth,
                                          style: AppTheme
                                              .themeData.textTheme.labelSmall!
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _dateController,
                                        style: AppTheme
                                            .themeData.textTheme.labelSmall!
                                            .copyWith(fontSize: 14),
                                        decoration: const InputDecoration(
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 5),
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: FaIcon(FontAwesomeIcons
                                                .calendarDays),
                                          ),
                                        ),
                                        onTap: () async {
                                          DateTime? date = DateTime(1900);

                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          date = await Picker()
                                              .birthDatePicker(context);
                                          age = DateTime.now().year -
                                              date!.year;

                                          _dateController.text = formatDate(
                                              date, [dd, '.', mm, '.', yyyy]);
                                        },
                                        onSaved: (value) {
                                          _dateController.text =
                                              value!.trim();
                                        },
                                        validator: (value) {
                                          if (value == '') {
                                            return 'Field cant be empty';
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
