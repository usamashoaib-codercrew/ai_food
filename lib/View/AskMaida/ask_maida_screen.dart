import 'package:ai_food/Constants/app_logger.dart';
import 'package:ai_food/Utils/resources/res/app_theme.dart';
import 'package:ai_food/Utils/utils.dart';
import 'package:ai_food/Utils/widgets/others/app_text.dart';
import 'package:ai_food/View/HomeScreen/widgets/providers/chat_bot_provider.dart';
import 'package:ai_food/View/recipe_info/recipe_info.dart';
import 'package:ai_food/config/app_urls.dart';
import 'package:ai_food/config/dio/app_dio.dart';
import 'package:ai_food/config/dio/spoonacular_app_dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AskMaidaScreen extends StatefulWidget {
  const AskMaidaScreen({Key? key}) : super(key: key);

  @override
  State<AskMaidaScreen> createState() => _AskMaidaScreenState();
}

class _AskMaidaScreenState extends State<AskMaidaScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;
  late AppDio dio;
  late SpoonAcularAppDio spoonDio;

  AppLogger logger = AppLogger();
  @override
  void initState() {
    dio = AppDio(context);
    spoonDio = SpoonAcularAppDio(context);

    logger.init();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<ChatBotProvider>(context, listen: true);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.1),
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   getRecipeInformation(id:);
        // }),
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Ask Maida",
            style: TextStyle(
                color: AppTheme.appColor,
                fontWeight: FontWeight.w600,
                fontSize: 24),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 0.7,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.appColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AppText.appText(
                    textAlign: TextAlign.center,
                    "There are instances where errors may be generated by the AI.",
                    textColor: AppTheme.whiteColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // customChat(),
            Expanded(
              child: Consumer<ChatBotProvider>(
                builder: (context, chatProvider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToBottom();
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: chatProvider.displayChatsWidget.length,
                    itemBuilder: (BuildContext context, int index) {
                      return chatProvider.displayChatsWidget[index];
                    },
                    addAutomaticKeepAlives: true,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        loadingProvider.isLoading
                            ? Image.asset(
                          "assets/images/loader.gif",
                          // width: 100,
                          height: 50,
                          color: AppTheme.appColor,
                        )
                            : const SizedBox.shrink(),
                        TextField(
                          onSubmitted: (value) {
                            if (_messageController.text.isNotEmpty) {
                              chatBotTalk();
                            }
                          },
                          controller: _messageController,
                          cursorColor: AppTheme.whiteColor,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          minLines: 1,
                          maxLines: 3,
                          style: TextStyle(color: AppTheme.whiteColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 30.0, top: 4, bottom: 4),
                            fillColor: AppTheme.appColor,
                            filled: true,
                            hintText: "Enter query...",
                            hintStyle: const TextStyle(
                              color: Color(0x80FFFFFF),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(80.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(80)),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.transparent),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(80)),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.transparent),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_messageController.text.isNotEmpty) {
                                    chatBotTalk();
                                  }
                                },
                                child: Icon(
                                  Icons.send_outlined,
                                  color: AppTheme.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void chatBotTalk() async {
    final chatsProvider = Provider.of<ChatBotProvider>(context, listen: false);
    chatsProvider.messageLoading(true);
    // const apiKey = '6fee21631c5c432dba9b34b9070a2d31';
    // const apiKey = '56806fa3f874403c8794d4b7e491c937';
    const apiKey = 'd9186e5f351240e094658382be62d948';
    final apiUrl =
        'https://api.spoonacular.com/food/converse?text=${_messageController.text}&apiKey=$apiKey';
    final response = await AppDio(context).get(path: apiUrl);
    if (response.statusCode == 200) {
      final resData = response.data;
      if (resData != null) {
        chatsProvider.displayChatWidgets(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 14),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.appColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(0),
                          ),
                        ),
                        child: AppText.appText(_messageController.text,
                            textColor: AppTheme.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: AppText.appText(
                    resData['answerText'],
                    textColor: AppTheme.appColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              resData['media'] == null || resData['media'].isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                children: resData['media']
                    .map<Widget>(
                      (item) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              width: 300,
                              height: 200,
                              imageUrl: "${item['image']}",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: Center(
                            child: AppText.appText(
                              item['title'],
                              textAlign: TextAlign.center,
                              // justifyText: true,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var inputString = item['link'];

                            RegExp urlRegex = RegExp(
                                r'https:\/\/spoonacular\.com\/recipes\/(.+)-(\d+)');

                            final match =
                            urlRegex.firstMatch(inputString);

                            if (match != null) {
                              String? substring = match.group(1);
                              String? digits = match.group(2);
                              getRecipeInformation(id: digits);

                              print("Substring: $substring");
                              print("Digits: $digits");
                            } else {
                              print("No match found");
                            }
                          },
                          child: SizedBox(
                            width: 300,
                            child: Center(
                              child: AppText.appText(
                                item['link'],
                                textAlign: TextAlign.center,
                                // justifyText: true,
                                textColor: AppTheme.whiteColor,
                                underLine: true,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        );
        _messageController.clear();
        chatsProvider.messageLoading(false);
      }
    } else {
      print('API request failed with status code: ${response.statusCode}');
      chatsProvider.messageLoading(false);
    }
  }

  getRecipeInformation({id}) async {
    print("gurirug23r3rhi3hrihior");
    const apiKey = '1acf1e54a67342b3bfa0f3d0b7888c6e';
    var url =
        "${AppUrls.spoonacularBaseUrl}/recipes/$id/information?includeNutrition=false&apiKey=$apiKey";
    final response = await spoonDio.get(path: url);

    if (response.statusCode == 200) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RecipeInfo(
          recipeData: response.data,
        ),
      ));
    } else {
      print('API request failed with status code: ${response.statusCode}');
    }
  }
}