import m from 'mithril'
import { useState, withHooks } from 'mithril-hooks'
import { If } from './if'
import { TrustHtml } from './trust-html'

type TreeValue = {
  [key: string]: any | TreeValue
}

type ObjectTreeProps = {
  path?: string
  root: TreeValue
  level?: number
}

export const ObjectTree = withHooks<ObjectTreeProps>(_ObjectTree)

function _ObjectTree(props: ObjectTreeProps) {

  const { root, path = '', level = 0 } = props

  const [collapsed, changeCollapsedState] = useState(true)

  function toggleCollapsed(e: Event) {
    e.preventDefault()
    changeCollapsedState(!collapsed)
  }

  if (!root) return <></>

  return (
    <div class='u-marginbottom-5'>
      <a class='fa fa-plus alt-link u-left' onclick={toggleCollapsed}>
        <span> </span>{path}
      </a>
      <br />
      <If condition={!collapsed}>
        <ul class='w-list-unstyled'>
          {
            Object
              .entries(root)
              .map(([key, value]) => {
                return (
                  <li>
                    {
                      typeof value === 'object' ?
                        <>{key}:<ObjectTree level={level + 1} root={value} path={`${path}${path ? '.' : ''}${key}`} /></>
                        :
                        <span>
                            <TrustHtml html={'&nbsp;'.repeat(level * 4)}/>
                            <i>{path ? `${path}.${key}` : key}</i> = <span href='#' class='alt-link'>{value}</span>
                        </span>
                    }
                  </li>
                )
              })
          }
        </ul>
      </If>
    </div>
  )

}
