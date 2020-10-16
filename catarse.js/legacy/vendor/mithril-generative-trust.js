import m from 'mithril';

/**
 * Convert a string to HTML entities
 */
String.prototype.toHtmlEntities = function() {
    return this.replace(/./gm, function(s) {
        return "&#" + s.charCodeAt(0) + ";";
    });
};

/**
 * Create string from HTML entities
 */
String.fromHtmlEntities = function(string) {
    return (string+"").replace(/&#\d+;/gm,function(s) {
        return String.fromCharCode(s.match(/\d+/gm)[0]);
    })
};

/**
 * @typedef {{tag: string, key: string, attrs: Object, children: VNode[], text: string, dom: Document, domSize: number, state: string, events: any[], instance: Document}} VNode  
 */

/**
 * @description Generates a mithril component tree based on parsed HTML provided.
 * @param {string} text 
 * @param {{tagsToFilter:string[], tagsFilterIsWhitelist:boolean, eliminateScriptTags:boolean = true}} options
 * @returns {VNode}
 */
export default function generativeTrust(text = '', options = {}, renderer = m) {
    const parser = new DOMParser();
    const parsedDom = parser.parseFromString(text, 'text/html');
    const children = parsedDom.body.childNodes;
    if (children.length > 0) {
        return createElementsFromDom(children, renderer);
    } else {
        return htmlentities(text);
    }
}

/**
 * @typedef RenderedNode
 * @property
 */

/**
 * @param {NodeList} nodes 
 * @param {(string, Object, RenderedNode | string) => RenderedNode} renderer 
 */
function createElementsFromDom(nodes, renderer) {
    
    const elements = [];
    
    for (let i = 0; i < nodes.length; i++) {
        const child = nodes.item(i);
        switch(child.nodeName) {
            case '#text': {
                elements.push(child.textContent);
                break;
            }

            default: {
                elements.push(createElementFromDom(child, renderer));
                break;
            }
        }
    }

    return elements;
}

/**
 * 
 * @param {Node} node 
 * @param {(string, Object, RenderedNode | string) => RenderedNode} renderer 
 */
function createElementFromDom(node, renderer) {
    const hasChildren = node.childNodes.length > 0;
    if (hasChildren) {
        return renderer(node.nodeName, createAttributesObject(node), createElementsFromDom(node.childNodes, renderer));
    } else {
        return renderer(node.nodeName, createAttributesObject(node));
    }
}

/**
 * 
 * @param {Node} node 
 */
function createAttributesObject(node) {
    const attributesObject = {};
    /** @type {NamedNodeMap} */
    const attributes = node.attributes;
    for (let i = 0; i < attributes.length; i++) {
        const attrib = attributes.item(i);
        attributesObject[attrib.name] = attrib.value;
    }
    return attributesObject;
}

function htmlentities(text) {
    return text
    .replace(/\&quot;/gi, '"')
    .replace(/\&apos;/gi, '\'')
    .replace(/\&amp;/gi, '&')
    .replace(/\&lt;/gi, '<')
    .replace(/\&gt;/gi, '>')
    .replace(/\&nbsp;/gi, ' ')
    .replace(/\&iexcl;/gi, '¡')
    .replace(/\&cent;/gi, '¢')
    .replace(/\&pound;/gi, '£')
    .replace(/\&curren;/gi, '¤')
    .replace(/\&yen;/gi, '¥')
    .replace(/\&brvbar;/gi, '¦')
    .replace(/\&sect;/gi, '§')
    .replace(/\&uml;/gi, '¨')
    .replace(/\&copy;/gi, '©')
    .replace(/\&ordf;/gi, 'ª')
    .replace(/\&laquo;/gi, '«')
    .replace(/\&not;/gi, '¬')
    .replace(/\&shy;/gi, '­')
    .replace(/\&reg;/gi, '®')
    .replace(/\&macr;/gi, '¯')
    .replace(/\&deg;/gi, '°')
    .replace(/\&plusmn;/gi, '±')
    .replace(/\&sup2;/gi, '²')
    .replace(/\&sup3;/gi, '³')
    .replace(/\&acute;/gi, '´')
    .replace(/\&micro;/gi, 'µ')
    .replace(/\&para;/gi, '¶')
    .replace(/\&middot;/gi, '·')
    .replace(/\&cedil;/gi, '¸')
    .replace(/\&sup1;/gi, '¹')
    .replace(/\&ordm;/gi, 'º')
    .replace(/\&raquo;/gi, '»')
    .replace(/\&frac14;/gi, '¼')
    .replace(/\&frac12;/gi, '½')
    .replace(/\&frac34;/gi, '¾')
    .replace(/\&iquest;/gi, '¿')
    .replace(/\&times;/gi, '×')
    .replace(/\&divide;/gi, '÷')
    .replace(/\&Agrave;/gi, 'À')
    .replace(/\&Aacute;/gi, 'Á')
    .replace(/\&Acirc;/gi, 'Â')
    .replace(/\&Atilde;/gi, 'Ã')
    .replace(/\&Auml;/gi, 'Ä')
    .replace(/\&Aring;/gi, 'Å')
    .replace(/\&AElig;/gi, 'Æ')
    .replace(/\&Ccedil;/gi, 'Ç')
    .replace(/\&Egrave;/gi, 'È')
    .replace(/\&Eacute;/gi, 'É')
    .replace(/\&Ecirc;/gi, 'Ê')
    .replace(/\&Euml;/gi, 'Ë')
    .replace(/\&Igrave;/gi, 'Ì')
    .replace(/\&Iacute;/gi, 'Í')
    .replace(/\&Icirc;/gi, 'Î')
    .replace(/\&Iuml;/gi, 'Ï')
    .replace(/\&ETH;/gi, 'Ð')
    .replace(/\&Ntilde;/gi, 'Ñ')
    .replace(/\&Ograve;/gi, 'Ò')
    .replace(/\&Oacute;/gi, 'Ó')
    .replace(/\&Ocirc;/gi, 'Ô')
    .replace(/\&Otilde;/gi, 'Õ')
    .replace(/\&Ouml;/gi, 'Ö')
    .replace(/\&Oslash;/gi, 'Ø')
    .replace(/\&Ugrave;/gi, 'Ù')
    .replace(/\&Uacute;/gi, 'Ú')
    .replace(/\&Ucirc;/gi, 'Û')
    .replace(/\&Uuml;/gi, 'Ü')
    .replace(/\&Yacute;/gi, 'Ý')
    .replace(/\&THORN;/gi, 'Þ')
    .replace(/\&szlig;/gi, 'ß')
    .replace(/\&agrave;/gi, 'à')
    .replace(/\&aacute;/gi, 'á')
    .replace(/\&acirc;/gi, 'â')
    .replace(/\&atilde;/gi, 'ã')
    .replace(/\&auml;/gi, 'ä')
    .replace(/\&aring;/gi, 'å')
    .replace(/\&aelig;/gi, 'æ')
    .replace(/\&ccedil;/gi, 'ç')
    .replace(/\&egrave;/gi, 'è')
    .replace(/\&eacute;/gi, 'é')
    .replace(/\&ecirc;/gi, 'ê')
    .replace(/\&euml;/gi, 'ë')
    .replace(/\&igrave;/gi, 'ì')
    .replace(/\&iacute;/gi, 'í')
    .replace(/\&icirc;/gi, 'î')
    .replace(/\&iuml;/gi, 'ï')
    .replace(/\&eth;/gi, 'ð')
    .replace(/\&ntilde;/gi, 'ñ')
    .replace(/\&ograve;/gi, 'ò')
    .replace(/\&oacute;/gi, 'ó')
    .replace(/\&ocirc;/gi, 'ô')
    .replace(/\&otilde;/gi, 'õ')
    .replace(/\&ouml;/gi, 'ö')
    .replace(/\&oslash;/gi, 'ø')
    .replace(/\&ugrave;/gi, 'ù')
    .replace(/\&uacute;/gi, 'ú')
    .replace(/\&ucirc;/gi, 'û')
    .replace(/\&uuml;/gi, 'ü')
    .replace(/\&yacute;/gi, 'ý')
    .replace(/\&thorn;/gi, 'þ')
    .replace(/\&yuml;/gi, 'ÿ')
    
}