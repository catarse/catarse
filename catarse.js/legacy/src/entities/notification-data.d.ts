export interface NotificationData {
    id:         string;
    user_id:    string;
    created_at: Date;
    label:      string;
    project_id: string;
    data:       Data;
    user_name:  string;
    user_public_name?: string;
    user_email: string;
}

interface Data {
    relations:     Relations;
    mail_config:   MailConfig;
    template_vars: TemplateVars;
}

interface MailConfig {
    to:        string;
    from:      string;
    reply_to:  string;
    from_name: string;
}

interface Relations {
    user_id:            string;
    reward_id:          string;
    project_id:         string;
    subscription_id:    string;
    catalog_payment_id: string;
}

interface TemplateVars {
    user:          ProjectOwner;
    reward:        Reward;
    payment:       Payment;
    project:       Project;
    platform:      Platform;
    subscription:  SubscriptionExtractedData;
    project_owner: ProjectOwner;
}

interface Payment {
    id:                             string;
    amount:                         number;
    boleto_url:                     string;
    card_brand:                     string;
    created_at:                     Date;
    refused_at:                     null;
    external_id:                    null;
    refunded_at:                    null;
    confirmed_at:                   Date;
    boleto_barcode:                 string;
    chargedback_at:                 null;
    fmt_created_at:                 string;
    fmt_refused_at:                 null;
    next_charge_at:                 Date;
    payment_method:                 string;
    fmt_refunded_at:                null;
    card_last_digits:               string;
    fmt_confirmed_at:               string;
    fmt_chargedback_at:             null;
    fmt_next_charge_at:             Date;
    boleto_expiration_date:         null;
    boleto_expiration_day_month:    null;
    subscription_period_month_year: string;
}

interface Platform {
    id:   string;
    name: string;
}

interface Project {
    project_id:                         number;
    in_reminder:                        boolean;
    id:                                 string;
    mode:                               string;
    name:                               string;
    card_info:                          CardInfo;
    permalink:                          string;
    expires_at:                         null;
    video_info:                         VideoInfo;
    external_id:                        string;
    online_days:                        null;
    fmt_expires_at:                     null;
    total_contributors:                 number;
    total_contributions:                number;
    total_subscriptions:                number;
    total_paid_in_contributions:        null;
    total_paid_in_active_subscriptions: number;
}

interface CardInfo {
    title:       null;
    image_url:   null;
    description: null;
}

interface VideoInfo {
    id:        null;
    provider:  null;
    embed_url: null;
    thumb_url: null;
}

interface ProjectOwner {
    id:              string;
    name:            string;
    email:           string;
    created_at:      Date;
    external_id:     string;
    document_type:   string;
    fmt_created_at:  string;
    document_number: string;
    public_name:     string;
}

interface Reward {
    id:                      string;
    title:                   string;
    deliver_at:              Date;
    external_id:             string;
    minimum_value:           number;
    fmt_deliver_at:          string;
    deliver_at_period:       string;
    welcome_message_body:    string;
    welcome_message_subject: string;
}

interface SubscriptionExtractedData {
    id:                          string;
    amount:                      number;
    status:                      string;
    paid_sum:                    number;
    reward_id:                   string;
    paid_count:                  number;
    project_id:                  string;
    next_charge_at:              Date;
    payment_method:              string;
    first_payment_at:            Date;
    period_month_year:           string;
    fmt_next_charge_at:          Date;
    last_payment_amount:         number;
    fmt_first_payment_at:        string;
    last_payment_payment_method: string;
}
