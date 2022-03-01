import {
    catarse,
    catarseMoments,
    commonPayment,
    commonAnalytics,
    commonProject,
    commonNotification,
    commonRecommender,
    commonCommunity,
    commonProxy
} from './api';

const models = {
    recommendedProjects1: commonRecommender.model('predictions/1'),
    recommendedProjects2: commonRecommender.model('predictions/2'),
    notificationTemplates: commonNotification.model('notification_templates'),
    userNotification: commonNotification.model('user_notifications'),
    userNotificationWithData: commonNotification.model('user_notifications_with_data'),
    commonNotificationTemplate: commonNotification.model('rpc/notification_template'),
    projectSubscriptionsPerDay: commonAnalytics.model('project_subscriptions_per_day'),
    projectSubscribersInfo: commonAnalytics.model('rpc/project_subscribers_info'),
    projectReward: commonProject.model('rewards'),
    projectSubscriber: commonProject.model('subscribers'),
    commonPayment: commonPayment.model('rpc/pay'),
    cancelSubscription: commonPayment.model('rpc/cancel_subscription'),
    restoreSubscription: commonPayment.model('rpc/restore_subscription'),
    commonPaymentInfo: commonPayment.model('rpc/payment_info'),
    commonPayments: commonPayment.model('payments'),
    subscriptionsPerMonth: commonPayment.model('subscriptions_per_month'),
    commonCreditCard: commonPayment.model('rpc/credit_card'),
    commonCreditCards: commonPayment.model('credit_cards'),
    commonSubscriptionUpgrade: commonPayment.model('rpc/upgrade_subscription'),
    setSubscriptionAnonymity: (uuid) => commonProxy.model(`v1/subscriptions/${uuid}/set_anonymity_state`),
    country: catarse.model('countries'),
    state: catarse.model('states'),
    userBalanceTransfers: catarse.model('user_balance_transfers'),
    contributionDetail: catarse.model('contribution_details'),
    contributionActivity: catarse.model('contribution_activities'),
    projectDetail: catarse.model('project_details'),
    userDetail: catarse.model('user_details'),
    balance: catarse.model('balances'),
    balanceTransaction: catarse.model('balance_transactions'),
    balanceTransfer: catarse.model('balance_transfers'),
    user: catarse.model('users'),
    survey: catarse.model('surveys'),
    userCreditCard: catarse.model('user_credit_cards'),
    bankAccount: catarse.model('bank_accounts'),
    bank: catarse.model('banks'),
    goalDetail: catarse.model('goals'),
    rewardDetail: catarse.model('reward_details'),
    projectReminder: catarse.model('project_reminders'),
    projectReport: catarse.model('project_reports'),
    contributions: catarse.model('contributions'),
    directMessage: catarse.model('direct_messages'),
    teamTotal: catarse.model('team_totals'),
    recommendedProjects: catarse.model('recommended_projects'),
    projectVisitorsPerDay: catarseMoments.model('project_visitors_per_day'),
    projectAccount: catarse.model('project_accounts'),
    projectAccountError: catarse.model('project_account_errors'),
    projectContribution: catarse.model('project_contributions'),
    projectContributiorsStat: catarse.model('project_stat_contributors'),
    projectPostDetail: catarse.model('project_posts_details'),
    projectContributionsPerDay: catarse.model('project_contributions_per_day'),
    projectContributionsPerLocation: catarse.model('project_contributions_per_location'),
    projectContributionsPerRef: catarse.model('project_contributions_per_ref'),
    projectFiscalId: catarse.model('project_fiscal_ids'),
    projectTransfer: catarse.model('project_transfers'),
    project: catarse.model('projects'),
    adminProject: catarse.model('admin_projects'),
    projectSearch: catarse.model('rpc/project_search'),
    publicTags: catarse.model('public_tags'),
    category: catarse.model('categories'),
    categoryTotals: catarse.model('category_totals'),
    categoryFollower: catarse.model('category_followers'),
    teamMember: catarse.model('team_members'),
    notification: catarse.model('notifications'),
    statistic: catarse.model('statistics'),
    successfulProject: catarse.model('successful_projects'),
    finishedProject: catarse.model('finished_projects'),
    userFriend: catarse.model('user_friends'),
    userFollow: catarse.model('user_follows'),
    followAllCreators: catarse.model('rpc/follow_all_creators'),
    sentSurveyCount: catarse.model('rpc/sent_survey_count'),
    answeredSurveyCount: catarse.model('rpc/answered_survey_count'),
    followAllFriends: catarse.model('rpc/follow_all_friends'),
    contributor: catarse.model('contributors'),
    userFollower: catarse.model('user_followers'),
    creatorSuggestion: catarse.model('creator_suggestions'),
    userContribution: catarse.model('user_contributions'),
    userSubscription: commonPayment.model('subscriptions'),
    subscriptionTransition: commonPayment.model('subscription_status_transitions'),
    shippingFee: catarse.model('shipping_fees'),
    deleteProject: catarse.model('rpc/delete_project'),
    cancelProject: catarse.model('rpc/cancel_project'),
    city: catarse.model('cities'),
    mailMarketingList: catarse.model('mail_marketing_lists'),
    commonUserDetails: commonCommunity.model('rpc/user_details'),
    rechargeSubscription: commonPayment.model('rpc/recharge_subscription'),
    unsubscribes: catarse.model('unsubscribes'),
    newSubscribersFromPeriod: commonAnalytics.model('rpc/new_subscribers_from_period'),
    projectReportExports: catarse.model('project_report_exports'),
};

models.teamMember.pageSize(40);
models.rewardDetail.pageSize(false);
models.subscriptionTransition.pageSize(false);
models.shippingFee.pageSize(false);
models.projectReminder.pageSize(false);
models.goalDetail.pageSize(false);
models.project.pageSize(30);
models.category.pageSize(50);
models.contributionActivity.pageSize(40);
models.successfulProject.pageSize(9);
models.finishedProject.pageSize(9);
models.country.pageSize(false);
models.state.pageSize(false);
models.publicTags.pageSize(false);
models.projectContribution.pageSize(9);
models.contributor.pageSize(9);
models.projectReward.pageSize(false);
models.recommendedProjects.pageSize(3);
models.bank.pageSize(400);
models.city.pageSize(200);
models.balanceTransfer.pageSize(9);
models.userSubscription.pageSize(9);
models.notificationTemplates.pageSize(200);


export default models;
