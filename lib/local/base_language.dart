import 'package:flutter/cupertino.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get pipNotAvailable;

  String get notifications;

  String get viewTheNewArrivals;

  String get clear;

  String get clearNotificationConfirmation;

  String get noNotificationsFound;

  String get skip;

  String get ago;

  String get justNow;

  String get blogs;

  String get leaveAReply;

  String get message;

  String get apply;

  String get protectedPostText;

  String get canNotViewPost;

  String get editComment;

  String get writeComment;

  String get commentUpdatedSuccessfully;

  String get deleteCommentConfirmation;

  String get tags;

  String get confirmYouWantToLeave;

  String get shareApp;

  String get reachUsMore;

  String get rateUs;

  String get loveItLetUsKnow;

  String get ourCommitmentToYour;

  String get streamNow;

  String get registerAndExploreOur;

  String get createYourAccountFor;

  String get youHaveBeenMissed;

  String get welcomeBack;

  String get profile;

  String get wooCommerce;

  String get pmpPayment;

  String get payment;

  String get products;

  String get orderStatus;

  String get orderNumber;

  String get viewOrdersOf;

  String get visaMastercard;

  String get africanMobilePayment;

  String get paymentBy;

  String get couponCode;

  String get discountAmount;

  String get enterCouponCode;

  String get noCouponsAvailable;

  String get applied;

  String get applyCoupon;

  String get appliedCoupon;

  String get cartDetails;

  String get subtotal;

  String get product;

  String get category;

  String get orderDetails;

  String get addRating;

  String get notFound;

  String get otherSettings;

  String get noDownloadsAvailable;

  String get youHavenTDownloadedAny;

  String get noCommentsAdded;

  String get letUsKnowWhat;

  String get contentAddedTo;

  String get willBeShownHere;

  String get isEmpty;

  String get detailsAreNotAvailable;

  String get noPlaylistsFoundFor;

  String get createPlaylistAndAdd;

  String get yourWatchListIsEmpty;

  String get keepTrackOfEverything;

  String get the;

  String get hasNotYetBeenAdded;

  String get content;

  String get found;

  String get reviewMembershipPlanAnd;

  String get theContentHasNot;

  String get noContentFound;

  String get currentDevice;

  String get model;

  String get deviceId;

  String get loginTime;

  String get areYouSureYouWantToLogOutFromThisDevice;

  String get continueWatching;

  String get manageDeviceText;

  String get manageDevices;

  String get youCanManageUnfamilier;

  String get signOutFromAllDevices;

  String get logOutAllDeviceConfirmation;

  String get manageAccount;

  String get lblPleaseRateUs;

  String get lbWaitForCommentApproval;

  String get lblRateAndReview;

  String get lblRating;

  String get lblAddYourReview;

  String get lblNoRatingsYet;

  String get ratings;

  String get viewMore;

  String get viewLess;

  String get description;

  String get failed;

  String get grantStoragePermissionTo;

  String get retry;

  String get editPlaylist;

  String get accountDeletedSuccessfully;

  String get watchYourNextList;

  String get playlists;

  String get membersOnly;

  String get thisContentIsFor;

  String get joinNow;

  String get alreadyAMember;

  String get youMustBeLogged;

  String get signUp;

  String get membershipExpiresAfter;

  String get noPlaylistsFound;

  String get selectPaymentMethod;

  String get endingWith;

  String get total;

  String get totalBilled;

  String get expiration;

  String get paymentMethod;

  String get accountHolderName;

  String get invoice;

  String get orderSummary;

  String get invoiceDetail;

  String get myAccount;

  String get myMemberships;

  String get myMembership;

  String get manageYourMembership;

  String get selectAndProceed;

  String get yourPlan;

  String get membershipPlans;

  String get makePayment;

  String get checkout;

  String get confirmEmail;

  String get emailAddress;

  String get city;

  String get state;

  String get postalCode;

  String get country;

  String get phone;

  String get address2;

  String get address1;

  String get billingAddress;

  String get free;

  String get pay;

  String get youHaveSelectedThe;

  String get accountDetails;

  String get pleaseEnterValidConfirmEmail;

  String get pastInvoices;

  String get viewAllInvoices;

  String get paid;

  String get amount;

  String get status;

  String get plan;

  String get chooseAMembershipPlan;

  String get youDontHaveMembership;

  String get edit;

  String get createPlaylist;

  String get playlist;

  String get deletePlaylist;

  String get areYouSureYouWantToDelete;

  String get createList;

  String get selectWhereYouWant;

  String get enterValidPlaylistName;

  String get playlistTitle;

  String get selectAnyPlaylist;

  String get addToPlaylist;

  String get saved;

  String get resume;

  String get startOver;

  String get doYouWishTo;

  String get resumeVideo;

  String get castDeviceList;

  String get notCloseCastScreen;

  String get refresh;

  String get noCastingDeviceFounded;

  String get cast;

  String get crew;

  String get closeConnection;

  String get deviceDisconnectedSuccessfully;

  String get deviceConnectedSuccessfully;

  String get changePasswordText;

  String get watchVideosOffline;

  String get tapToSpeak;

  String get listening;

  String get danger;

  String get areYouSureYou;

  String get deleteAccount;

  String get downloadedVideos;

  String get guestDownloads;

  String get deleteMovieSuccessfully;

  String get areYouSureYouWantDeleteThisMovie;

  String get delete;

  String get viewDetails;

  String get remove;

  String get unLike;

  String get downloads;

  String get download;

  String get downloaded;

  String get downloading;

  String get downloadFailed;

  String get done;

  String get downloadSuccessfully;

  String get quality;

  String get player;

  String get date;

  String get links;

  String get sources;

  String get settings;

  String get dontHaveAnAccount;

  String get watchNow;

  String get signIn;

  String get somethingWantWrongPleaseContactYourAdministrator;

  String get writeSomething;

  String get commentAdded;

  String get sActing;

  String get addAComment;

  String get yourInterNetNotWorking;

  String get somethingWentWrong;

  String get thisFieldIsRequired;

  String get pleaseTryAgain;

  String get addReply;

  String get viewreply;

  String get readLess;

  String get readMore;

  String get noData;

  String get upgradePlan;

  String get subscribeNow;

  String get recommendedMovies;

  String get upcomingMovies;

  String get upcomingVideo;

  String get relatedVideos;

  String get relatedMovies;

  String get action;

  String get movies;

  String get tVShows;

  String get videos;

  String get home;

  String get more;

  String get membershipPlan;

  String get generalSettings;

  String get accountSettings;

  String get others;

  String get termsConditions;

  String get privacyPolicy;

  String get logOut;

  String get doYouWantToLogout;

  String get cancel;

  String get ok;

  String get search;

  String get searchHere;

  String get searchMoviesTvShowsVideos;

  String get watchList;

  String get pleaseWait;

  String get addedToList;

  String get myList;

  String get changePassword;

  String get all;

  String get allCategories;

  String get mostViewed;

  String get personalInfo;

  String get knownFor;

  String get knownCredits;

  String get placeOfBirth;

  String get alsoKnownAs;

  String get birthday;

  String get deathDay;

  String get password;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get bothPasswordShouldBeMatched;

  String get submit;

  String get changeAvatar;

  String get firstName;

  String get lastName;

  String get email;

  String get editProfile;

  String get save;

  String get viewInfo;

  String get loginNow;

  String get previous;

  String get next;

  String get trailerLink;

  String get runTime;

  String get episodes;

  String get loginToAddComment;

  String get views;

  String get starring;

  String get getStarted;

  String get login;

  String get forgotPassword;

  String get registerNow;

  String get enterValidEmail;

  String get forgotPasswordData;

  String get username;

  String get emailIsInvalid;

  String get passWordNotMatch;

  String get signUpNow;

  String get createAccount;

  String get signUpToDiscoverOurFeature;

  String get streamTermsConditions;

  String get back;

  String get jumanjiTheNextLevel;

  String get title;

  String get viewAll;

  String get language;

  String get selectTheme;

  String get as;

  String get validTill;

  String get resultFor;

  String get episode;

  String get likes;

  String get like;

  String get likedByYou;

  String get comments;

  String get comment;

  String get passwordLengthShouldBeMoreThan6;

  String get aboutUs;

  String get no;

  String get yes;

  String get profileHasBeenUpdatedSuccessfully;

  String get pleaseEnterPassword;

  String get pleaseEnterNewPassword;

  String get pleaseEnterConfirmPassword;

  String get pleaseEnterComment;

  String get genre;

  String get yourMembershipCancellationWill;

  String get noOfferingsFound;

  String get kindlyCancelTheCurrent;

  String get thisIsYourCurrent;

  String get revenueCatIdentifierMissMach;

  String get subscriptionDetailsRestored;

  String get update;

  String get rememberMe;

  String get youAreLoggedInLetsGetStarted;

  String get areYouSureYouWantToDeleteThisMovieFromDownloads;

  String get youHaveBeenLoggedOutFromThisDevice;

  String get demoUserCanTPerformThisAction;

  String get youHaveBeenLoggedOutSuccessfully;

  String get movieAddedToYourWatchlist;

  String get youHaveBeenSignedOutFromAllDevices;

  String get areYouSureYouWantToDeleteThisFromYourContinueWatching;

  String get editReview;

  String get editYourReview;

  String get areYouSureYouWantToDeleteThisReview;

  String get youHaveAlreadySubmittedReview;

  String get pleaseProvideRating;

  String get read;

  String get unRead;

  String get movieRemovedFromYourWatchlist;

  String get noGenresFound;

  String get noDataFound;

  String get pleaseLoginToSearch;

  String get pleaseEnterMessageBeforeSubmitting;

  String get yourCommentAddedSuccessfully;

  String get pleaseSelectRatingBeforeSubmittingYourReview;

  String get cannotUseOldPassword;

  String get movieDeletedSuccessfullyFromDownloads;

  String get videoUnavailable;

  String get videoUnavailableMessage;

  String get pleaseCheckLinkOrPrivacySettings;

  String get advertisement;

  String get skipAd;

  String get skipIn;

  String get live;

  String get tvGuide;

  String get liveTV;

  String get recommendedChannels;

  String get channelCategories;

  String get privacyLinkCheckMessage;

  String get liveStreamErrorMessage;

  String get videoNotFound;

  String get videoUnavailableTapToPlay;

  String get noProgram;

  String get noProgramsAvailable;

  String get yesterday;

  String get today;

  String get tomorrow;

  String get loginToWatchMessage;

  String get dayTime;

  String get channels;

  String get recommendedForYou;

  String get myRentals;

  String get manageRentals;

  String get validity;

  String get info;

  String get upgradeToWatch;

  String get subscribeToWatch;

  String get rentOrUpgradeToWatch;

  String get rentOrSubscribeToWatch;

  String get recommended;

  String get noRentalsFound;

  String get type;

  String get purchaseDate;

  String get expires;

  String get paymentStatus;

  String get totalAmount;

  String get day;

  String get days;

  String get rentFor;

  String get unpaid;

  String get rent;

  String get rented;

  String get paymentCompletedSuccessfully;

  String get checkoutUrlNotAvailable;

  String get lifetimeAccess;

  String get upgrade;

  String get subscribe;

  String get expiringOn;

  String get yourReminders;

  String get areYouSureAbout;

  String get thisActionWillTerminate;

  String get keepSubscription;

  String get noActiveSubscriptions;

  String get youReLoggedInLetS;

  String get youReBack;

  String get itSGreatToSee;

  String get egHintEmail;

  String get minimumPasswordLengthShould;

  String get orContinueWith;

  String get welcomeTo;

  String get createYourAccountAnd;

  String get userName;

  String get accountCreatedSuccessfully;

  String get pleaseEnterYourEmail;

  String get pleaseEnterAValid;

  String get passwordsDoNotMatch;

  String get alreadyHaveAnAccount;

  String get loginSuccessful;

  String get loginFailed;

  String get castsCrew;

  String get failedToLoadEpisode;

  String get egPassword;

  String get successfullyRemovedFromContinue;

  String get downloadMovie;

  String get downloadEpisode;

  String get downloadVideo;

  String get forText;

  String get enterYourRegisteredEmail;

  String get backToLogin;

  String get searchCountries;

  String get verificationCodeSentTo;

  String get otpVerification;

  String get didnTGetTheOtp;

  String get resendOtp;

  String get verify;

  String get pleaseEnterCompleteOtp;

  String get invalidOtpPleaseEnter;

  String get phoneNumber;

  String get enterPhoneNumber;

  String get phoneNumberIsRequired;

  String get pleaseEnterAValidPhoneNumber;

  String get getVerificationCode;

  String get continueLabel;

  String get noBlogsFound;

  String get actorDetailsNotFound;

  String get removeFromHistory;

  String get loadingSection;

  String get noChennelsFound;

  String get downloadCompleteSuccessfully;

  String get remindMe;

  String get playlistCreatedSuccessfully;

  String get enterPlalistName;

  String get selectWhereYouWantToCreate;

  String get select;

  String get keepYourFavouriteStories;

  String get deleteConfirmation;

  String get expired;

  String get active;

  String get expiry;

  String get purchased;

  String get downloadInvoice;

  String get thisPlanIsAlready;

  String get selectedSubscriptionPlanIs;

  String get allSubscription;

  String get restore;

  String get noInvoiceAvailable;

  String get id;

  String get pleaseChoosePaymentMethod;

  String get thisPlanIsAlreadyActive;

  String get selectedSubscriptionPlanIsAlreadyActive;

  String get card;

  String get reviewSubmittedSuccessfully;

  String get rateThis;

  String get shareYourFavouriteThoughts;

  String get reviewDeletedSuccessfully;

  String get reviewUpdatedSuccessfully;

  String get yourReview;

  String get reviews;

  String get basedOnIndividualRating;

  String get noReviewsYet;

  String get beTheFirstOne;

  String get reviewsRatings;

  String get removeDeviceToContinue;

  String get deviceManagement;

  String get standardPlan;

  String get devicesUsed;

  String get usage;

  String get youHaveReachedThe;

  String get yourDevice;

  String get otherDevice;

  String get signedOutFromAll;

  String get notificationReadSuccessfully;

  String get doYouReallyWant;

  String get areYouSureYouWantToSignOut;

  String get signOut;

  String get subscriptionHistory;

  String get importantInfoAwaitsPeek;

  String get share;

  String get app;

  String get failedToStartDownload;

  String get yourOrderIs;

  String get paymentUrlNotFound;

  String get paymentSuccessful;

  String get yourPaymentHasBeen;

  String get holdOnWeReSavingYour;

  String get checkYourOneTime;

  String get ofLabel;

  String get loading;

  String get errorLabel;

  String get onLabel;

  String get allReviews;

  String get thisIsYourCurrentDevice;

  String get androidPhoneTablet;

  String get lastUsed;

  String get devices;

  String get comingSoon;

  String get allow;

  String get notNow;

  String get notificationPermissionText;

    String get allowNotifications;

  String get reminderSet;

  String get resumeWatching;

  String get startFromBeginning;

  String get nowPlaying;

  String get noPlan;

  String get noLimit;

  String get lifetime;

  String get then;

  String get sessionExpired;

  String get releases;
}
