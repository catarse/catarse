import m from 'mithril'
import { commonNotification } from '../api'
import models from '../models'
import ProjectEditSaveBtn from '../c/project-edit-save-btn'
import { useEffect, useRef, useState, withHooks } from 'mithril-hooks'
import { HTMLRenderer } from '../shared/components/html-renderer'
import projectVM from '../vms/project-vm'
import subscriptionVM from '../vms/subscription-vm'
import rewardVM from '../vms/reward-vm'
import userVM from '../vms/user-vm'
import { ProjectDetails, ProjectDetailsUser, RewardDetails, Subscription, SubscriptionPayment, UserDetails } from '../entities'
import { getUserDetailsWithUserId } from '../shared/services/user/get-updated-current-user'
import { If } from '../shared/components/if'
import { ObjectTree } from '../shared/components/object-tree'
import _ from 'underscore'
import { cleanUndefinedFromObject } from '../utils/clean-undefined-from-object'
import { AdminNotificationsList } from './admin-notifications-list'
import { Loader } from '../shared/components/loader'

export default withHooks(_AdminNotifications)

async function loadTemplates() {
  const templates = commonNotification.paginationVM(models.notificationTemplates, 'label.asc')

  await templates.firstPage({})
  return templates.collection()
}

function _AdminNotifications() {
  const [templates, setTemplates] = useState<NotificationTemplate[]>([])
  const [errorMessage, setErrorMessage] = useState('')
  const [selectedNotification, setSelectedNotification] = useState<NotificationTemplate | undefined>()
  const [isSaving, setIsSaving] = useState(false)
  const [isLoadingTemplates, setIsLoadingTemplates] = useState(true)
  const [subject, setSubject] = useState('')
  const [body, setBody] = useState('')

  function onSelectTemplate(notificationTemplate?: NotificationTemplate) {
    setSelectedNotification(notificationTemplate)
    if (notificationTemplate) {
      setSubject(notificationTemplate.subject || notificationTemplate.default_subject)
      setBody(notificationTemplate.template || notificationTemplate.default_template)
    }
  }

  async function updateSelectedTemplate(event: Event) {
    try {
      setIsSaving(true)
      event?.preventDefault()
      const updateData = {
        data: {
          label: selectedNotification.label,
          subject,
          template: body,
        },
      }

      await models.commonNotificationTemplate.postWithToken(updateData, null, {})
      await loadTemplatesList()
    } catch (error) {
      setErrorMessage(`Failed to save template: ${error.message}.`)
    } finally {
      setIsSaving(false)
    }
  }

  async function loadTemplatesList() {
    try {
      setIsLoadingTemplates(true)
      setTemplates(await loadTemplates())
    } catch (error) {
      setErrorMessage(`Failed to load templates: ${error.message}.`)
    } finally {
      setIsLoadingTemplates(false)
    }
  }

  useEffect(() => {
    loadTemplatesList()
  }, [])

  if (isLoadingTemplates) return <Loader />

  return (
    <>
      <div id="notifications-admin">
        <div class="section">
          <div class="w-container">
            <div class="w-row">
              <div class="w-col w-col-3"></div>
              <div class="w-col w-col-6">
                <div class="w-form">
                  <NotificationSelect list={templates} onSelect={onSelectTemplate} />
                </div>
              </div>
              <div class="w-col w-col-3"></div>
            </div>
          </div>
        </div>
        <div class="divider"></div>
        <AdminNotificationsList templates={templates}/>
        <div class="divider"></div>
        {selectedNotification && (
          <>
            <NotificationTemplateEditor
              label={selectedNotification.label}
              subject={subject}
              body={body}
              onChangeTemplateSubject={setSubject}
              onChangeTemplateBody={setBody}
            />
            <footer style="height: 100px">
              <ProjectEditSaveBtn loading={() => isSaving} onSubmit={updateSelectedTemplate} hideMarginLeft={true} />
            </footer>
          </>
        )}
      </div>
    </>
  )
}

export type NotificationTemplate = {
  created_at: string
  default_subject: string
  default_template: string
  label: string
  subject: string
  template: string
}

type NotificationSelectProps = {
  list: NotificationTemplate[]
  onSelect(item?: NotificationTemplate): void
}

const NotificationSelect = withHooks<NotificationSelectProps>(_NotificationSelect)

function _NotificationSelect(props: NotificationSelectProps) {
  const { list, onSelect } = props

  return (
    <form>
      <div class="fontsize-larger u-marginbottom-10 u-text-center">Notificações</div>
      <select oninput={event => onSelect(findNotificationByLabel(list, event.target.value))} class="medium text-field w-select">
        <option value={undefined}>Selectione uma notificação</option>
        {list.map(item => (
          <option value={item.label}>{item.label}</option>
        ))}
      </select>
    </form>
  )
}

function findNotificationByLabel(list: NotificationTemplate[], label: string) {
  return list.find(item => item.label === label)
}

type NotificationTemplateEditorProps = {
  label: string
  subject: string
  body: string
  onChangeTemplateSubject(subjectTemplate: string): void
  onChangeTemplateBody(bodyTemplate: string): void
}

const NotificationTemplateEditor = withHooks<NotificationTemplateEditorProps>(_NotificationTemplateEditor)

function _NotificationTemplateEditor(props: NotificationTemplateEditorProps) {
  const { label, subject, body, onChangeTemplateSubject, onChangeTemplateBody } = props

  if (!label || !subject || !body) return <Loader />

  const [variables, setVariables] = useState<LoadVariablesResult>()

  const [showIdFields, setShowIdFields] = useState(false)

  return (
    <div class="u-marginbottom-80 bg-gray section">
      <div class="w-container">
        <div class="w-row">
          <div class="w-col w-col-6">
            <div class="fontsize-base fontweight-semibold u-marginbottom-20 u-text-center">
              <span class="fa fa-code"></span> HTML
            </div>

            <div class="w-form">
              <form>
                <div class="u-marginbottom-20 w-row">
                  <div class="w-col w-col-2">
                    <label class="fontsize-small">Label</label>
                  </div>
                  <div class="w-col w-col-10">
                    <div class="fontsize-small">{label}</div>
                  </div>
                </div>

                <div class="w-row">
                  <div class="w-col w-col-2">
                    <label class="fontsize-small">Subject</label>
                  </div>

                  <div class="w-col w-col-10">
                    <input
                      type="text"
                      class="positive text-field w-input"
                      value={subject}
                      oninput={e => onChangeTemplateSubject(e.target.value)}
                    />
                  </div>
                </div>

                <label class="fontsize-small">
                  Content
                  <a
                    class="alt-link u-right"
                    onclick={e => {
                      e.preventDefault()
                      setShowIdFields(!showIdFields)
                    }}
                  >
                    Ver variáveis
                  </a>
                  <If condition={showIdFields}>
                    <VariablesLoader
                      objectRefTree={{
                        project_id: ['project', 'project_owner'],
                        user_id: ['user'],
                        subscription_id: ['subscription'],
                        reward_id: ['reward'],
                        payment_id: ['payment'],
                      }}
                      variablesIdNames={['project_id', 'subscription_id', 'reward_id', 'payment_id', 'user_id']}
                      onLoad={setVariables}
                    />
                  </If>
                </label>
                <textarea
                  rows="20"
                  class="positive text-field w-input"
                  value={body}
                  oninput={e => onChangeTemplateBody(e.target.value)}
                ></textarea>
              </form>
            </div>
          </div>

          <div class="w-col w-col-6">
            <div class="fontsize-base fontweight-semibold u-marginbottom-20 u-text-center">
              <span class="fa fa-eye"></span> Visualização
            </div>
            <HTMLRenderer html={subject} variables={variables} />
            <HTMLRenderer html={body} variables={variables} />
          </div>
        </div>
      </div>
    </div>
  )
}

const VariablesLoader = withHooks<VariablesLoaderProps>(_VariablesLoader)

type VariablesLoaderProps = {
  variablesIdNames: string[]
  objectRefTree: {
    [key: string]: string[]
  }
  onLoad(result: LoadVariablesResult): void
}

function _VariablesLoader(props: VariablesLoaderProps) {
  const { objectRefTree, variablesIdNames, onLoad } = props

  const idsMap = useRef<Map<string, string>>()
  const [variables, setVariables] = useState<LoadVariablesResult>({})
  const [variablesMap, setVariablesMap] = useState()

  useEffect(() => {
    idsMap.current = new Map<string, string>()
    for (const idName of variablesIdNames) {
      idsMap.current.set(idName, '')
    }
  }, [])

  async function loadAllVariables(e: Event, id?: string) {
    e.preventDefault()
    e.stopPropagation()
    try {
      const idsObject = id ?
        { [id]: idsMap.current.get(id) }
        :
        variablesIdNames.reduce((memo, idName) =>
            ({ ...memo, [idName]: idsMap.current.get(idName) }),
            {})
      const response = await loadBasicVariables(idsObject)
      const result = cleanUndefinedFromObject(response)
      const nextSetVariables = { ...variables, ...result }
      onLoad(nextSetVariables)
      setVariables(nextSetVariables)
    } catch (error) {
      console.log('Error', error)
    }
  }

  return (
    <div class='w-row'>
      {idsMap.current &&
        variablesIdNames.map(idName => (
          <div class='w-row'>
            <div class='w-row u-marginbottom-5'>
              <div class='w-col w-col-10'>
                <input
                  class="positive text-field w-input"
                  placeholder={idName}
                  type="text"
                  value={idsMap.current.get(idName)}
                  oninput={e => idsMap.current.set(idName, e.target.value)}
                />
              </div>
              <div class='w-col w-col-2'>
                <button class='btn btn-medium' onclick={e => loadAllVariables(e, idName)}>
                  <i class='fa fa-refresh'></i>
                </button>
              </div>
            </div>
            <div class='w-row'>
              {objectRefTree[idName].map(mapField => (
                <ObjectTree path={mapField} root={variables[mapField] } />
              ))}
            </div>
          </div>
        ))}
        <div class='w-row'>
            <button class='btn btn-medium u-marginbottom-20' onclick={loadAllVariables}>
                Recarregar todas as variáveis
            </button>
        </div>
    </div>
  )
}

type LoadVariablesConfigIds = {
  [id: string]: string
}

type LoadVariablesResult = {
  project?: ProjectDetails
  project_owner?: ProjectDetailsUser
  subscription?: Subscription
  reward?: RewardDetails
  payment?: SubscriptionPayment
  user?: UserDetails
}

async function loadBasicVariables(config: LoadVariablesConfigIds): Promise<LoadVariablesResult> {
  const { project_id, subscription_id, reward_id, payment_id, user_id } = config

  // from project id
  let project
  let project_owner

  if (project_id) {
    try {
      project = await projectVM.fetchProject(project_id, false).then(_.first)
      project_owner = project?.user
    } catch (error) {
      // TODO: set an error message to the screen
      console.error('error', error)
    }
  }

  // from subscription id
  let subscription
  if (subscription_id) {
    try {
      subscription = await subscriptionVM.getSubscription(subscription_id).then(_.first)
    } catch (error) {
      // TODO: set an error message to the screen
      console.error('error', error)
    }
  }

  // from reward id
  let reward
  if (reward_id) {
    try {
      reward = await rewardVM.rewardLoader(reward_id).then(_.first)
    } catch (error) {
      // TODO: set an error message to the screen
      console.error('error', error)
    }
  }

  // from payment id
  let payment
  if (payment_id) {
    try {
      payment = await subscriptionVM.getPayment(payment_id).then(_.first)
    } catch (error) {
      // TODO: set an error message to the screen
      console.error('error', error)
    }
  }

  // from user id
  let user
  if (user_id) {
    try {
      user = await getUserDetailsWithUserId(Number(user_id)).then(user => user['_user'])
    } catch (error) {
      // TODO: set an error message to the screen
      console.error('error', error)
    }
  }

  return {
    project,
    project_owner,
    subscription,
    payment,
    reward,
    user,
  }
}
