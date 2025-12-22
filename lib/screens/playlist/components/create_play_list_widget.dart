import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/common/data_model.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class CreatePlayListWidget extends StatefulWidget {
  final VoidCallback? onPlaylistCreated;
  final String? playlistType;

  const CreatePlayListWidget({this.onPlaylistCreated, this.playlistType});

  @override
  State<CreatePlayListWidget> createState() => _CreatePlayListWidgetState();
}

class _CreatePlayListWidgetState extends State<CreatePlayListWidget> {
  TextEditingController _playlistTitleController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  final _playlistFromKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (playlistStore.playListTypeList.isEmpty) {
      playlistStore.initializePlaylistTypes();
    }

    if (widget.playlistType != null) {
      final selectedType = playlistStore.playListTypeList.firstWhere(
        (element) => element.data == widget.playlistType,
        orElse: () => playlistStore.playListTypeList.first,
      );
      playlistStore.setSelectedPlaylistTypeModel(selectedType);
    } else if (playlistStore.selectedPlaylistTypeModel == null) {
      playlistStore.setSelectedPlaylistTypeModel(playlistStore.playListTypeList.first);
    }
  }

  @override
  void dispose() {
    _playlistTitleController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void createPlayList(BuildContext context, {required String playlistName, required String playlistType}) async {
    final success = await playlistStore.createPlaylist(playlistName: playlistName, playlistType: playlistType);

    if (success) {
      toast(language.playlistCreatedSuccessfully);
      finish(context);
      widget.onPlaylistCreated?.call();
    } else {
      toast(language.somethingWentWrong);
      finish(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35))),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.only(left: 24, top: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 40),
          child: Form(
            key: _playlistFromKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.createPlaylist, style: primaryTextStyle(size: 18)),
                16.height,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.height,
                    AppTextField(
                      title: language.playlistTitle,
                      titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                      textFieldType: TextFieldType.OTHER,
                      controller: _playlistTitleController,
                      keyboardType: TextInputType.text,
                      textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                      decoration: InputDecoration(
                        hintText:language.enterPlalistName,
                        hintStyle: secondaryTextStyle(),
                        prefixIcon: Image.asset(ic_add_playlist, width: 16, height: 16, color: context.primaryColor).paddingAll(12),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ],
                ),
                24.height,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.selectWhereYouWantToCreate, style: primaryTextStyle(size: textSecondarySizeGlobal.toInt())),
                    12.height,
                    Observer(
                      builder: (_) => DropdownButtonHideUnderline(
                        child: DropdownButton<DataModel>(
                          isExpanded: true,
                          dropdownColor: Colors.grey[900],
                          icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
                          style: primaryTextStyle(),
                          items: playlistStore.playListTypeList.map((value) {
                            return DropdownMenuItem(child: Text(value.title, style: primaryTextStyle()), value: value);
                          }).toList(),
                          onChanged: (DataModel? type) {
                            playlistStore.setSelectedPlaylistTypeModel(type);
                          },
                          value: playlistStore.selectedPlaylistTypeModel,
                          hint: Text(language.select, style: secondaryTextStyle()),
                        ),
                      ),
                    ),
                  ],
                ),
                32.height,
                Observer(
                  builder: (_) {
                    return playlistStore.isCreatingPlaylist
                        ? Center(child: CircularProgressIndicator(color: colorPrimary, strokeWidth: 2))
                        : AppButton(
                            text: language.createPlaylist,
                            textStyle: boldTextStyle(size: textPrimarySizeGlobal.toInt()),
                            color: context.primaryColor,
                            splashColor: context.primaryColor.withValues(alpha: 0.2),
                            elevation: 0,
                            width: context.width(),
                            height: 48,
                            onTap: () async {
                              if (_playlistFromKey.currentState!.validate()) {
                                _playlistFromKey.currentState!.save();
                                hideKeyboard(context);
                                final selectedType = playlistStore.selectedPlaylistTypeModel?.data ?? playlistMovie;
                                createPlayList(context, playlistName: _playlistTitleController.text.trim(), playlistType: selectedType);
                              }
                            },
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
