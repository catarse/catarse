import { TimeDescription } from "./time-description";
import { ProjectIntegration } from "./project-integration";

export type ProjectDetails = {
    about_html: string | null;
    address: ProjectAddress;
    admin_notes: string | null;
    admin_tag_list: string | null;
    budget: string | null;
    can_cancel: boolean;
    can_request_transfer: boolean;
    category_id: number;
    category_name: string;
    city_id: number | null;
    common_id: string | null;
    content_rating: number;
    contributed_by_friends: boolean;
    cover_image: string | null;
    elapsed_time: TimeDescription;
    expires_at: string | null;
    goal: number | null;
    has_cancelation_request: boolean;
    headline: string;
    id: number;
    in_reminder: boolean;
    integrations: ProjectIntegration[];
    is_admin_role: boolean;
    is_adult_content: boolean;
    is_expired: boolean | null;
    is_owner_or_admin: boolean;
    is_published: boolean;
    large_image: string | null;
    mode: string;
    name: string | null;
    online_date: string | null;
    online_days: number | null;
    open_for_contributions: boolean;
    original_image: string | null;
    permalink: string | null;
    pledged: number;
    posts_count: number;
    progress: number;
    project_id: number;
    recommended: boolean;
    remaining_time: TimeDescription;
    reminder_count: number;
    sent_to_analysis_at: string | null;
    service_fee: number;
    small_image: string | null;
    state: string;
    state_order: string;
    tag_list: string | null;
    thumb_image: string | null;
    total_contributions: number;
    total_contributors: number;
    total_posts: number;
    tracker_snippet_html: string | null;
    user: ProjectDetailsUser;
    user_id: number;
    user_signed_in: boolean;
    video_cover_image: string | null;
    video_embed_url: string | null;
    video_url: string | null;
    zone_expires_at: string | null;
    zone_online_date: string | null;
}

type ProjectAddress = {
    city: string | null;
    state_acronym: string | null;
    state: string | null;
};

type ProjectDetailsUser = {
    id: number;
    name: string;
    public_name: string;
}