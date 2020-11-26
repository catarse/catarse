import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';

const getFriendsListVM = () => {
    models.userFriend.pageSize(9);
    const friendListVM = catarse.paginationVM(models.userFriend, 'following.asc,total_contributed_projects.desc', { Prefer: 'count=exact' });

    return h.createBasicPaginationVMWithAutoRedraw(friendListVM);
};

const getCreatorsListVM = () => {
    models.creatorSuggestion.pageSize(9);
    const creatorsListVM = catarse.paginationVM(models.creatorSuggestion, 'following.asc, total_published_projects.desc, total_contributed_projects.desc', {
        Prefer: 'count=exact',
    });

    return h.createBasicPaginationVMWithAutoRedraw(creatorsListVM);
};

const getUserFollowsListVM = () => {
    models.userFollow.pageSize(9);
    const userFollowsListVM = catarse.paginationVM(models.userFollow, 'created_at.desc', { Prefer: 'count=exact' });
    return h.createBasicPaginationVMWithAutoRedraw(userFollowsListVM);
};

const getUserFollowersListVM = () => {
    models.userFollower.pageSize(9);
    const userFollowersListVM = catarse.paginationVM(models.userFollower, 'following.asc,created_at.desc', { Prefer: 'count=exact' });
    return h.createBasicPaginationVMWithAutoRedraw(userFollowersListVM);
};

export { getFriendsListVM, getCreatorsListVM, getUserFollowsListVM, getUserFollowersListVM };
