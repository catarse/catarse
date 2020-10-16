'use strict'

const m = require('mithril/render/hyperscript')
const cssauron = require('cssauron')
const code = require('yields-keycode')

const PD = '//'

function copyObj(data) {
  return Object.assign(Object.create(Object.getPrototypeOf(data)), data)
}

function identity(thing) {
  return thing
}

function isBoolean(thing) {
  return typeof thing === 'boolean'
}

function isString(thing) {
  return Object.prototype.toString.call(thing) === '[object String]'
}

function isNumber(thing) {
  return typeof thing === 'number'
}

function isStringOrNumber(thing) {
  return isString(thing) || isNumber(thing)
}

function getContent(thing) {
  if (!thing) {
    return ''
  }
  if (isString(thing)) {
    return thing
  }
  if (isNumber(thing)) {
    return '' + thing
  }
  if (thing.tag === '#' || thing.tag === '[') {
    return getContent(thing.children)
  }
  if (isArray(thing)) {
    return thing.map(getContent).join('')
  }
  return ''
}

function isArray(thing) {
  return Object.prototype.toString.call(thing) === '[object Array]'
}

function isComponent(thing) {
  return (
    (thing && (typeof thing === 'object' && thing.view)) ||
    isFunction(thing) ||
    isClass(thing)
  )
}

function isFunction(thing) {
  return typeof thing === 'function' && !isClass(thing)
}

function isClass(thing) {
  return typeof thing === 'function' && /^\s*class\s+/.test(thing.toString())
}

function call(thing) {
  return thing()
}

function consoleLogFn(a) {
  const util = require('util')
  // eslint-disable-next-line no-console
  console.log(
    util.inspect(a, {
      colors: true,
      depth: null,
    })
  )
}

const language = cssauron({
  tag: 'tag',
  contents(node) {
    const content = node.text == null ? '' : '' + node.text

    if (isStringOrNumber(node.children) || isBoolean(node.children)) {
      return '' + content + node.children
    }

    return '' + content + getContent(node.renderedChildren)
  },
  id(node) {
    if (node.attrs) {
      return node.attrs.id || ''
    }
    return ''
  },
  class(node) {
    if (node.attrs) {
      return node.attrs.className
    }
    return ''
  },
  parent: 'parent',
  children(node) {
    return node && isArray(node.renderedChildren)
      ? node.renderedChildren.filter(identity)
      : []
  },
  attr(node, attr) {
    if (node.attrs) {
      return node.attrs[attr] == null ? '' : '' + node.attrs[attr]
    }
  },
})

function join(arrays) {
  return arrays.reduce(function(result, array) {
    return result.concat(array)
  }, [])
}

function renderComponents(states, onremovers) {
  function renderComponent(component, treePath) {
    if (isFunction(component.tag)) {
      component.instance = component.tag(component)
    } else if (isClass(component.tag)) {
      const Component = component.tag
      component.instance = new Component(component)
    } else {
      component.instance = copyObj(component.tag)
    }

    if (!states[treePath]) {
      component.state = component.instance
      if (component.instance.oninit) {
        component.instance.oninit(component)
        states[treePath] = component.state
      }
      if (component.instance.onremove) {
        onremovers.push(function() {
          component.instance.onremove(component)
        })
      }
      if (component.instance._captureVnode) {
        component.instance._captureVnode(component)
      }
    } else {
      component.state = states[treePath]
      if (component.instance.onupdate) {
        component.instance.onupdate(component)
      }
    }
    return component.instance.view(component)
  }

  return function renderNode(parent, node, treePath) {
    if (!node) {
      return ''
    }
    if (isArray(node)) {
      return node.map(function(subnode, index) {
        return renderNode(parent, subnode, treePath + PD + index)
      })
    }
    if (isComponent(node.tag)) {
      const componentTreePath = treePath + PD + (node.key || '')
      return renderNode(
        parent,
        renderComponent(node, componentTreePath),
        componentTreePath
      )
    }

    if (node.children) {
      node.renderedChildren = renderNode(
        node,
        node.children,
        treePath + PD + (node.key || '')
      )
    }

    if (isString(node.tag)) {
      node.parent = parent
    }

    return node
  }
}

function scan(render) {
  const states = {}
  const onremovers = []
  const renderNode = renderComponents(states, onremovers)
  const api = {
    onremovers,
    redraw() {
      api.rootNode = renderNode(undefined, render(api), 'ROOT')
    },
  }
  api.redraw()

  function find(selectorString, node) {
    return select(language(selectorString))(node)
  }

  function select(matchesSelector) {
    return function matches(node) {
      if (!node) {
        return []
      }
      if (isArray(node)) {
        return join(
          node.filter(identity).map(function(childNode) {
            return matches(childNode)
          })
        )
      }
      const foundNodes = []
      if (matchesSelector(node)) {
        foundNodes.push(node)
      }
      if (
        isBoolean(node.children) ||
        isStringOrNumber(node.children) ||
        !node.children
      ) {
        return foundNodes
      }
      node.renderedChildren.filter(identity).map(function(child) {
        if (typeof child === 'string' || typeof child === 'number') {
          return
        }
        child.parent = node
        child.inspect = function() {
          return {
            tag: child.tag,
            children: child.children,
            text: child.text,
            attrs: child.attrs,
          }
        }
      })
      return foundNodes.concat(matches(node.renderedChildren))
    }
  }

  function first(selector) {
    const node = find(selector, api.rootNode)[0]
    if (!node) {
      throw new Error('No element matches ' + selector)
    }
    return node
  }

  function has(selector) {
    return find(selector, api.rootNode).length > 0
  }

  function contains(value, node) {
    return !!find(':contains(' + value + ')', node).length
  }

  function shouldHaveAtLeast(minCount, selector) {
    const actualCount = find(selector, api.rootNode).length
    if (actualCount < minCount) {
      throw new Error(
        'Wrong count of elements that matches "' +
          selector +
          '"\n  expected: >=' +
          minCount +
          '\n  actual: ' +
          actualCount
      )
    }
    return true
  }

  function shouldHave(expectedCount, selector) {
    if (!selector) {
      return isArray(expectedCount)
        ? shouldHaveCollection(expectedCount)
        : shouldHaveAtLeast(1, expectedCount)
    }

    const actualCount = find(selector, api.rootNode).length
    if (actualCount !== expectedCount) {
      throw new Error(
        'Wrong count of elements that matches "' +
          selector +
          '"\n  expected: ' +
          expectedCount +
          '\n  actual: ' +
          actualCount
      )
    }
    return true
  }

  function shouldHaveCollection(selectors) {
    selectors.forEach(function(selector) {
      shouldHaveAtLeast(1, selector)
    })
    return true
  }

  function shouldNotHave(selector) {
    shouldHave(0, selector)
    return true
  }

  function shouldContain(string) {
    if (!contains(string, api.rootNode)) {
      throw new Error('Expected "' + string + '" not found!')
    }
    return true
  }

  function shouldNotContain(string) {
    if (contains(string, api.rootNode)) {
      throw new Error('Unexpected "' + string + '" found!')
    }
    return true
  }

  function setValue(selector, string, silent) {
    const attrs = first(selector).attrs
    const event = {
      currentTarget: { value: string },
      target: { value: string },
    }
    attrs.oninput && attrs.oninput(event)
    attrs.onchange && attrs.onchange(event)
    attrs.onkeyup && attrs.onkeyup(event)
    silent || api.redraw()
  }

  function trigger(eventName) {
    return function(selector, event, silent) {
      const attrs = first(selector).attrs
      attrs[eventName](event)
      silent = silent || (event && event.redraw === false)
      silent || api.redraw()
    }
  }

  function triggerKey(eventName) {
    const fire = trigger('on' + eventName)
    return function handleEvent(selector, key, event, silent) {
      const keyCode = isString(key) ? code(key) : key
      const defaultEvent = {
        altKey: false,
        shiftKey: false,
        ctrlKey: false,
        type: eventName,
        keyCode,
        which: keyCode,
      }
      fire(
        selector,
        Object.assign({}, defaultEvent, event || {}),
        !!silent
      )
    }
  }

  shouldHave.at = {
    least: shouldHaveAtLeast,
  }

  api.first = first
  api.has = has
  api.contains = function(value) {
    return contains(value, api.rootNode)
  }
  api.find = function(selector) {
    return find(selector, api.rootNode)
  }
  api.setValue = setValue
  ;[
    'focus',
    'click',
    'blur',
    'mousedown',
    'mouseup',
    'mouseover',
    'mouseout',
    'mouseenter',
    'mouseleave',
  ].map(function(eventName) {
    api[eventName] = trigger('on' + eventName)
  })
  api.contextMenu = trigger('contextmenu')
  api.keydown = triggerKey('keydown')
  api.keypress = triggerKey('keypress')
  api.keyup = triggerKey('keyup')
  api.trigger = function(selector, eventName, event, silent) {
    trigger(eventName)(selector, event, silent)
  }
  api.should = {
    not: {
      have: shouldNotHave,
      contain: shouldNotContain,
    },
    have: shouldHave,
    contain: shouldContain,
  }
  api.log = function(selector, logFn = consoleLogFn) {
    logFn(api.find(selector))
    return api
  }
  return api
}

function init(viewOrComponentOrRootNode, nodeOrAttrs) {
  let api = {}
  if (isComponent(viewOrComponentOrRootNode)) {
    api = scan(function(api) {
      viewOrComponentOrRootNode._captureVnode = function(vnode) {
        api.vnode = vnode
      }
      return m(viewOrComponentOrRootNode, nodeOrAttrs)
    })
  } else {
    // assume that first argument is rendered view
    api = scan(function() {
      return viewOrComponentOrRootNode
    })
  }
  api.onremove = function() {
    api.onremovers.filter(isFunction).map(call)
  }
  return api
}

module.exports = init
