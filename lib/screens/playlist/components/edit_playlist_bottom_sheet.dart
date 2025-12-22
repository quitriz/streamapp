import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/playlist_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class EditPlaylistBottomSheet extends StatefulWidget {
  final PlaylistModel playlist;
  final VoidCallback? onPlaylistUpdated;

  const EditPlaylistBottomSheet({Key? key, required this.playlist, this.onPlaylistUpdated}) : super(key: key);

  @override
  State<EditPlaylistBottomSheet> createState() => _EditPlaylistBottomSheetState();
}

class _EditPlaylistBottomSheetState extends State<EditPlaylistBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _playlistNameController;

  @override
  void initState() {
    super.initState();
    _playlistNameController = TextEditingController(text: widget.playlist.playlistName);
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  Future<void> _updatePlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    hideKeyboard(context);

    Map req = {"title": _playlistNameController.text.trim(), "playlist_id": widget.playlist.playlistId};

    appStore.setLoading(true);

    try {
      await createOrEditPlaylist(request: req, type: widget.playlist.postType).then((value) {
        toast(value.message.validate());
        appStore.setLoading(false);
        finish(context);
        widget.onPlaylistUpdated?.call();
      });
    } catch (e) {
      appStore.setLoading(false);
      toast(language.somethingWentWrong);
      log("====>>>>Update Playlist Error : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.editPlaylist, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 8),
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    controller: _playlistNameController,
                    keyboardType: TextInputType.text,
                    textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                    decoration: InputDecoration(
                      hintText: language.enterPlalistName,
                      hintStyle: secondaryTextStyle(),
                      prefixIcon: Image.asset(ic_playlist, width: 16, height: 16, color: context.primaryColor).paddingAll(12),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
              ),
              42.height,
              Row(
                children: [
                  AppButton(
                    text: language.cancel,
                    textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                    onTap: () => finish(context),
                    color: appBackground,
                    elevation: 0,
                    width: context.width(),
                  ).expand(),
                  16.width,
                  AppButton(
                    text: language.save,
                    textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                    onTap: () {
                      _updatePlaylist();
                    } ,
                    color: context.primaryColor,
                    elevation: 0,
                    width: context.width(),
                  ).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
