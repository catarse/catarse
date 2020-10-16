import m from "mithril";
import prop from "mithril/stream";
import _ from "underscore";
import h from "../h";
import userVM from "../vms/user-vm";
import inlineError from "./inline-error";

const I18nScope = _.partial(h.i18nScope, "users.edit.notifications_fields");
const userNotifications = {
    oninit: function(vnode) {
        const contributedProjects = h.RedrawStream();
        const subscribedProjects = h.RedrawStream();
        const projectReminders = h.RedrawStream();
        const mailMarketingLists = h.RedrawStream();
        const user_id = vnode.attrs.userId;
        const showNotifications = h.toggleProp(false, true);
        const error = h.RedrawStream(false);
        const unsubscribedNewsProjects = h.RedrawStream([]);

        userVM
            .getUserUnsubscribesProjects(user_id)
            .then(unsubscribedNewsProjects)
            .catch(error);

        userVM
            .getUserProjectReminders(user_id)
            .then(projectReminders)
            .catch(error);

        userVM
            .getMailMarketingLists()
            .then(data => mailMarketingLists(generateListHandler(data)))
            .catch(error);

        userVM
            .getUserContributedProjects(user_id, null)
            .then(contributedProjects)
            .catch(error);

        userVM
            .getUserSubscribedProjects(user_id, null)
            .then(subscribedProjects)
            .catch(error);

        const generateListHandler = list => {
            const user_lists = vnode.attrs.user.mail_marketing_lists;
            return _.map(list, (item, i) => {
                const user_signed =
                    !_.isEmpty(user_lists) &&
                    !_.isUndefined(
                        _.find(user_lists, userList =>
                            userList.marketing_list
                                ? userList.marketing_list.list_id ===
                                  item.list_id
                                : false
                        )
                    );
                const handler = {
                    item,
                    in_list: user_signed,
                    should_insert: prop(false),
                    should_destroy: prop(false),
                    isInsertInListState: h.toggleProp(false, true),
                    hovering: prop(false)
                };
                handler.isInsertInListState(!handler.in_list);
                return handler;
            });
        };

        const getUserMarketingListId = list => {
            const currentList = _.find(
                vnode.attrs.user.mail_marketing_lists,
                userList => userList.marketing_list.list_id === list.list_id
            );

            return currentList ? currentList.user_marketing_list_id : null;
        };

        const isOnCurrentList = (userLists, currentList) =>
            Boolean(
                _.find(userLists, userList => {
                    if (userList.marketing_list) {
                        return (
                            userList.marketing_list.list_id ===
                            currentList.list_id
                        );
                    }

                    return false;
                })
            );

        vnode.state = {
            contributedProjects,
            subscribedProjects,
            mailMarketingLists,
            showNotifications,
            projectReminders,
            error,
            generateListHandler,
            getUserMarketingListId,
            isOnCurrentList,
            unsubscribedNewsProjects
        };
    },
    view: function({ state, attrs }) {
        const user = attrs.user,
            reminders = state.projectReminders(),
            projects_collection = (state.contributedProjects() || []).concat(
                state.subscribedProjects() || []
            ),
            marketing_lists = state.mailMarketingLists(),
            unsubscribedNewsProjects = state.unsubscribedNewsProjects(),
            user_contributed_and_subscribed_projects_count =
                projects_collection.length;

        return m(
            "[id='notifications-tab']",
            state.error()
                ? m(inlineError, {
                      message: "Erro ao carregar a página."
                  })
                : m(
                      `form.simple_form.edit_user[accept-charset='UTF-8'][action='/${
                          window.I18n.locale
                      }/users/${
                          user.id
                      }'][method='post'][novalidate='novalidate']`,
                      [
                          m("input[name='utf8'][type='hidden'][value='✓']"),
                          m(
                              "input[name='_method'][type='hidden'][value='patch']"
                          ),
                          m(
                              `input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`
                          ),
                          m(
                              "input[id='anchor'][name='anchor'][type='hidden'][value='notifications']"
                          ),
                          m(".w-container", [
                              m(
                                  ".w-row",
                                  m(
                                      ".w-col.w-col-10.w-col-push-1",
                                      m(".w-form.card.card-terciary", [
                                          m(".w-row.u-marginbottom-20", [
                                              m(
                                                  ".w-col.w-col-4",
                                                  m(
                                                      ".fontweight-semibold.fontsize-small.u-marginbottom-10",
                                                      "Newsletters:"
                                                  )
                                              ),
                                              m(
                                                  ".w-col.w-col-8",
                                                  _.isEmpty(marketing_lists)
                                                      ? h.loader()
                                                      : _.map(
                                                            marketing_lists,
                                                            (_item, i) => {
                                                                const item =
                                                                    _item.item;

                                                                return m(
                                                                    ".card.u-marginbottom-20.u-radius.u-text-center-small-only",
                                                                    m(
                                                                        ".w-row",
                                                                        [
                                                                            m(
                                                                                ".w-sub-col.w-col.w-col-6",
                                                                                m(
                                                                                    "img",
                                                                                    {
                                                                                        src: window.I18n.t(
                                                                                            `newsletters.${
                                                                                                item.list_id
                                                                                            }.image_src`,
                                                                                            I18nScope()
                                                                                        )
                                                                                    }
                                                                                )
                                                                            ),
                                                                            m(
                                                                                ".w-col.w-col-6",
                                                                                [
                                                                                    m(
                                                                                        ".fontsize-base.fontweight-semibold",
                                                                                        window.I18n.t(
                                                                                            `newsletters.${
                                                                                                item.list_id
                                                                                            }.title`,
                                                                                            I18nScope()
                                                                                        )
                                                                                    ),
                                                                                    m(
                                                                                        ".fontsize-small.u-marginbottom-30",
                                                                                        window.I18n.t(
                                                                                            `newsletters.${
                                                                                                item.list_id
                                                                                            }.description`,
                                                                                            I18nScope()
                                                                                        )
                                                                                    ),
                                                                                    _item.should_insert() ||
                                                                                    _item.should_destroy()
                                                                                        ? m(
                                                                                              "input[type='hidden']",
                                                                                              {
                                                                                                  name: `user[mail_marketing_users_attributes][${i}][mail_marketing_list_id]`,
                                                                                                  value:
                                                                                                      item.id
                                                                                              }
                                                                                          )
                                                                                        : "",
                                                                                    _item.should_destroy()
                                                                                        ? m(
                                                                                              "input[type='hidden']",
                                                                                              {
                                                                                                  name: `user[mail_marketing_users_attributes][${i}][id]`,
                                                                                                  value: state.getUserMarketingListId(
                                                                                                      item
                                                                                                  )
                                                                                              }
                                                                                          )
                                                                                        : "",
                                                                                    _item.should_destroy()
                                                                                        ? m(
                                                                                              "input[type='hidden']",
                                                                                              {
                                                                                                  name: `user[mail_marketing_users_attributes][${i}][_destroy]`,
                                                                                                  value: _item.should_destroy()
                                                                                              }
                                                                                          )
                                                                                        : "",
                                                                                    m(
                                                                                        "button.btn.btn-medium.w-button",
                                                                                        {
                                                                                            class: !_item.isInsertInListState()
                                                                                                ? "btn-terciary"
                                                                                                : null,
                                                                                            onclick: event => {
                                                                                                // If user already has this list, click should enable destroy state
                                                                                                if (
                                                                                                    state.isOnCurrentList(
                                                                                                        user.mail_marketing_lists,
                                                                                                        item
                                                                                                    )
                                                                                                ) {
                                                                                                    _item.should_destroy(
                                                                                                        true
                                                                                                    );

                                                                                                    return;
                                                                                                }
                                                                                                _item.should_insert(
                                                                                                    true
                                                                                                );
                                                                                            },
                                                                                            onmouseenter: () => {
                                                                                                _item.hovering(
                                                                                                    true
                                                                                                );
                                                                                            },
                                                                                            onmouseout: () => {
                                                                                                _item.hovering(
                                                                                                    false
                                                                                                );
                                                                                            }
                                                                                        },
                                                                                        _item.in_list
                                                                                            ? _item.hovering()
                                                                                                ? "Descadastrar"
                                                                                                : "Assinado"
                                                                                            : "Assinar"
                                                                                    )
                                                                                ]
                                                                            )
                                                                        ]
                                                                    )
                                                                );
                                                            }
                                                        )
                                              )
                                          ]),
                                          m(".w-row.u-marginbottom-20", [
                                              m(
                                                  ".w-col.w-col-4",
                                                  m(
                                                      ".fontweight-semibold.fontsize-small.u-marginbottom-10",
                                                      "Projetos que você apoiou:"
                                                  )
                                              ),
                                              m(
                                                  ".w-col.w-col-8",
                                                  m(".w-checkbox.w-clearfix", [
                                                      m(
                                                          "input[name=user[subscribed_to_project_posts]][type='hidden'][value='0']"
                                                      ),
                                                      m(
                                                          `input.w-checkbox-input${
                                                              user.subscribed_to_project_posts
                                                                  ? "[checked='checked']"
                                                                  : ""
                                                          }[id='user_subscribed_to_project_posts'][name=user[subscribed_to_project_posts]][type='checkbox'][value='1']`
                                                      ),
                                                      m(
                                                          "label.w-form-label.fontsize-base.fontweight-semibold",
                                                          " Quero receber atualizações dos projetos"
                                                      ),
                                                      m(
                                                          ".u-marginbottom-20",
                                                          m(
                                                              "a.alt-link[href='javascript:void(0);']",
                                                              {
                                                                  onclick:
                                                                      state
                                                                          .showNotifications
                                                                          .toggle
                                                              },
                                                              ` Gerenciar as notificações de ${user_contributed_and_subscribed_projects_count} projetos`
                                                          )
                                                      ),
                                                      state.showNotifications()
                                                          ? m(
                                                                "ul.w-list-unstyled.u-radius.card.card-secondary[id='notifications-box']",
                                                                [
                                                                    !_.isEmpty(
                                                                        projects_collection
                                                                    )
                                                                        ? _.map(
                                                                              projects_collection,
                                                                              project => {
                                                                                  const project_id = Number(
                                                                                      !!project.project_external_id
                                                                                          ? project.project_external_id
                                                                                          : project.project_id
                                                                                  );
                                                                                  const found_index =
                                                                                      unsubscribedNewsProjects.findIndex(
                                                                                          value =>
                                                                                              value.project_id ===
                                                                                              project_id
                                                                                      ) >=
                                                                                      0;
                                                                                  const unsubscribed_truthy = !!project.unsubscribed;
                                                                                  const is_unsubscribed =
                                                                                      unsubscribed_truthy ||
                                                                                      found_index;

                                                                                  return m(
                                                                                      "li",
                                                                                      m(
                                                                                          ".w-checkbox.w-clearfix",
                                                                                          [
                                                                                              m(
                                                                                                  `input[id='unsubscribes_${project_id}'][type='hidden'][value='']`,
                                                                                                  {
                                                                                                      name: `unsubscribes[${project_id}]`
                                                                                                  }
                                                                                              ),
                                                                                              m(
                                                                                                  `input.w-checkbox-input${
                                                                                                      is_unsubscribed
                                                                                                          ? ""
                                                                                                          : "[checked='checked']"
                                                                                                  }[type='checkbox'][value='1'][id='user_unsubscribes_${
                                                                                                      project.project_id
                                                                                                  }']`,
                                                                                                  {
                                                                                                      name: `unsubscribes[${project_id}]`
                                                                                                  }
                                                                                              ),
                                                                                              m(
                                                                                                  "label.w-form-label.fontsize-small",
                                                                                                  project.project_name
                                                                                              )
                                                                                          ]
                                                                                      )
                                                                                  );
                                                                              }
                                                                          )
                                                                        : ""
                                                                ]
                                                            )
                                                          : ""
                                                  ])
                                              )
                                          ]),
                                          m(".w-row.u-marginbottom-20", [
                                              m(
                                                  ".w-col.w-col-4",
                                                  m(
                                                      ".fontweight-semibold.fontsize-small.u-marginbottom-10",
                                                      "Social:"
                                                  )
                                              ),
                                              m(
                                                  ".w-col.w-col-8",
                                                  m(".w-checkbox.w-clearfix", [
                                                      m(
                                                          "input[name=user[subscribed_to_friends_contributions]][type='hidden'][value='0']"
                                                      ),
                                                      m(
                                                          `input.w-checkbox-input${
                                                              user.subscribed_to_friends_contributions
                                                                  ? "[checked='checked']"
                                                                  : ""
                                                          }[id='user_subscribed_to_friends_contributions'][name=user[subscribed_to_friends_contributions]][type='checkbox'][value='1']`
                                                      ),
                                                      m(
                                                          "label.w-form-label.fontsize-small",
                                                          "Um amigo apoiou ou lançou um projeto"
                                                      )
                                                  ])
                                              ),
                                              m(
                                                  ".w-col.w-col-8",
                                                  m(".w-checkbox.w-clearfix", [
                                                      m(
                                                          "input[name=user[subscribed_to_new_followers]][type='hidden'][value='0']"
                                                      ),
                                                      m(
                                                          `input.w-checkbox-input${
                                                              user.subscribed_to_new_followers
                                                                  ? "[checked='checked']"
                                                                  : ""
                                                          }[id='user_subscribed_to_new_followers'][name=user[subscribed_to_new_followers]][type='checkbox'][value='1']`
                                                      ),
                                                      m(
                                                          "label.w-form-label.fontsize-small",
                                                          "Um amigo começou a me seguir"
                                                      )
                                                  ])
                                              )
                                          ]),
                                          m(".w-row.u-marginbottom-20", [
                                              m(
                                                  ".w-col.w-col-4",
                                                  m(
                                                      ".fontweight-semibold.fontsize-small.u-marginbottom-10",
                                                      "Lembretes de projetos:"
                                                  )
                                              ),
                                              m(".w-col.w-col-8", [
                                                  !_.isEmpty(reminders)
                                                      ? _.map(
                                                            reminders,
                                                            reminder =>
                                                                m(
                                                                    ".w-checkbox.w-clearfix",
                                                                    [
                                                                        m(
                                                                            `input[id='user_reminders_${
                                                                                reminder.project_id
                                                                            }'][type='hidden'][value='false']`,
                                                                            {
                                                                                name: `user[reminders][${
                                                                                    reminder.project_id
                                                                                }]`
                                                                            }
                                                                        ),
                                                                        m(
                                                                            `input.w-checkbox-input[checked='checked'][type='checkbox'][value='1'][id='user_reminders_${
                                                                                reminder.project_id
                                                                            }']`,
                                                                            {
                                                                                name: `user[reminders][${
                                                                                    reminder.project_id
                                                                                }]`
                                                                            }
                                                                        ),
                                                                        m(
                                                                            "label.w-form-label.fontsize-small",
                                                                            m(
                                                                                `a.alt-link[href='/projects/${
                                                                                    reminder.project_id
                                                                                }?ref=ctrse_profile_reminder'][target='_blank']`,
                                                                                reminder.project_name
                                                                            )
                                                                        )
                                                                    ]
                                                                )
                                                        )
                                                      : ""
                                              ])
                                          ])
                                      ])
                                  )
                              ),
                              m(
                                  ".u-margintop-30",
                                  m(
                                      ".w-container",
                                      m(
                                          ".w-row",
                                          m(
                                              ".w-col.w-col-4.w-col-push-4",
                                              m(
                                                  "input.btn.btn-large[id='save'][name='commit'][type='submit'][value='Salvar']"
                                              )
                                          )
                                      )
                                  )
                              )
                          ])
                      ]
                  )
        );
    }
};

export default userNotifications;
