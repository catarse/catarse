import _ from 'underscore';
import prop from 'mithril/stream';

const { CatarseAnalytics } = window;

const defaultFormat = /(\d{1,4})/g;

const slice = [].slice,
    indexOf = [].indexOf || function (item) { for (let i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

const cards = [
    {
        type: 'elo',
        patterns: [401178, 401179, 431274, 438935, 451416, 457393, 457631, 457632, 504175, 506699, 5067, 509, 627780, 636297, 636368, 650, 6516, 6550],
        format: defaultFormat,
        length: [16],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'maestro',
        patterns: [5018, 502, 503, 506, 56, 58, 639, 6220, 67],
        format: defaultFormat,
        length: [12, 13, 14, 15, 16, 17, 18, 19],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'forbrugsforeningen',
        patterns: [600],
        format: defaultFormat,
        length: [16],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'dankort',
        patterns: [5019],
        format: defaultFormat,
        length: [16],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'visa',
        patterns: [4],
        format: defaultFormat,
        length: [13, 16],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'mastercard',
        patterns: [51, 52, 53, 54, 55, 22, 23, 24, 25, 26, 27],
        format: defaultFormat,
        length: [16],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'amex',
        patterns: [34, 37],
        format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/,
        length: [15],
        cvvLength: [3, 4],
        luhn: true
    }, {
        type: 'dinersclub',
        patterns: [30, 36, 38, 39],
        format: /(\d{1,4})(\d{1,6})?(\d{1,4})?/,
        length: [14],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'discover',
        patterns: [60, 64, 65, 622],
        format: defaultFormat,
        length: [16],
        cvvLength: [3],
        luhn: true
    }, {
        type: 'unionpay',
        patterns: [62, 88],
        format: defaultFormat,
        length: [16, 17, 18, 19],
        cvvLength: [3],
        luhn: false
    }, {
        type: 'jcb',
        patterns: [35],
        format: defaultFormat,
        length: [16],
        cvvLength: [3],
        luhn: true
    }
];

const inputCardType = (num) => {
    let ref;
    if (!num) {
        return null;
    }
    return ((ref = cardFromNumber(num)) != null ? ref.type : void 0) || null;
};

const cardFromType = (type) => {
    let card,
        i,
        len;
    for (i = 0, len = cards.length; i < len; i++) {
        card = cards[i];
        if (card.type === type) {
            return card;
        }
    }
};

const setCardType = (e, type) => {
    let $target,
        allTypes,
        card,
        cardType,
        val;
    $target = e.currentTarget;
    val = $target.value;
    cardType = inputCardType(val) || 'unknown';
    return type(cardType);
};

const formatBackCardNumber = (e, cardNumberProp) => {
    let $target,
        value;
    $target = e.currentTarget;
    value = $target.value;
    if (e.which !== 8) {
        return;
    }
    if (($target.selectionStart != null) && $target.selectionStart !== value.length) {
        return;
    }
    if (/\d\s$/.test(value)) {
        e.preventDefault();
        return setTimeout(() => $target.value = cardNumberProp(value.replace(/\d\s$/, '')));
    } else if (/\s\d?$/.test(value)) {
        e.preventDefault();
        return setTimeout(() => $target.value = cardNumberProp(value.replace(/\d$/, '')));
    }
};

const replaceFullWidthChars = (str) => {
    let chars,
        chr,
        fullWidth,
        halfWidth,
        i,
        idx,
        len,
        value;
    if (str == null) {
        str = '';
    }
    fullWidth = '\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19';
    halfWidth = '0123456789';
    value = '';
    chars = str.split('');
    for (i = 0, len = chars.length; i < len; i++) {
        chr = chars[i];
        idx = fullWidth.indexOf(chr);
        if (idx > -1) {
            chr = halfWidth[idx];
        }
        value += chr;
    }
    return value;
};

const safeVal = (value, $target, cardNumberProp) => {
    let currPair,
        cursor,
        digit,
        error,
        error1,
        last,
        prevPair;
    try {
        cursor = $target.selectionStart;
    } catch (error1) {
        error = error1;
        cursor = null;
    }
    last = $target.value;
    $target.value = cardNumberProp(value);
    if (cursor !== null && ($target === document.activeElement)) {
        if (cursor === last.length) {
            cursor = value.length;
        }
        if (last !== value) {
            prevPair = last.slice(cursor - 1, +cursor + 1 || 9e9);
            currPair = value.slice(cursor - 1, +cursor + 1 || 9e9);
            digit = value[cursor];
            if (/\d/.test(digit) && prevPair === (`${digit} `) && currPair === (` ${digit}`)) {
                cursor += 1;
            }
        }
        $target.selectionStart = cursor;
        return $target.selectionEnd = cursor;
    }
};

const reFormatCardNumber = (e, cardNumberProp) => {
    const $target = e.currentTarget;
    return setTimeout(() => {
        let value;
        value = $target.value;
        value = replaceFullWidthChars(value);
        value = formatCardNumber(value);
        return safeVal(value, $target, cardNumberProp);
    });
};

const formatCardNumber = function (num) {
    let card,
        groups,
        ref,
        upperLength;
    num = num.replace(/\D/g, '');
    card = cardFromNumber(num);
    if (!card) {
        return num;
    }
    upperLength = card.length[card.length.length - 1];
    num = num.slice(0, upperLength);
    if (card.format.global) {
        return (ref = num.match(card.format)) != null ? ref.join(' ') : void 0;
    }
    groups = card.format.exec(num);
    if (groups == null) {
        return;
    }
    groups.shift();
    groups = _.filter(groups, n => n);
    return groups.join(' ');
};

const formatCardInputNumber = (e, cardNumberProp) => {
    let $target,
        card,
        digit,
        length,
        re,
        upperLength,
        value;
    digit = String.fromCharCode(e.which);
    if (!/^\d+$/.test(digit)) {
        return;
    }
    $target = e.currentTarget;
    value = $target.value;
    card = cardFromNumber(value + digit);
    length = (value.replace(/\D/g, '') + digit).length;
    upperLength = 16;
    if (card) {
        upperLength = card.length[card.length.length - 1];
    }
    if (length >= upperLength) {
        return;
    }
    if (($target.selectionStart != null) && $target.selectionStart !== value.length) {
        return;
    }
    if (card && card.type === 'amex') {
        re = /^(\d{4}|\d{4}\s\d{6})$/;
    } else {
        re = /(?:^|\s)(\d{4})$/;
    }
    if (re.test(value)) {
        e.preventDefault();
        return setTimeout(() => $target.value = cardNumberProp(`${value} ${digit}`));
    } else if (re.test(value + digit)) {
        e.preventDefault();
        return setTimeout(() => $target.value = cardNumberProp(`${value + digit} `));
    }
};

const cardFromNumber = (num) => {
    let card,
        i,
        j,
        len,
        len1,
        p,
        pattern,
        ref;
    num = (`${num}`).replace(/\D/g, '');
    for (i = 0, len = cards.length; i < len; i++) {
        card = cards[i];
        ref = card.patterns;
        for (j = 0, len1 = ref.length; j < len1; j++) {
            pattern = ref[j];
            p = `${pattern}`;
            if (num.substr(0, p.length) === p) {
                return card;
            }
        }
    }
};

const hasTextSelected = ($target) => {
    let ref;
    if (($target.selectionStart != null) && $target.selectionStart !== $target.selectionEnd) {
        return true;
    }
    if ((typeof document !== 'undefined' && document !== null ? (ref = document.selection) != null ? ref.createRange : void 0 : void 0) != null) {
        if (document.selection.createRange().text) {
            return true;
        }
    }
    return false;
};

const restrictNumeric = (e) => {
    let input;
    if (e.metaKey || e.ctrlKey) {
        return true;
    }
    if (e.which === 32) {
        return false;
    }
    if (e.which === 0) {
        return true;
    }
    if (e.which < 33) {
        return true;
    }
    input = String.fromCharCode(e.which);
    return !!/[\d\s]/.test(input);
};

const restrictCardNumber = (e) => {
    let $target,
        card,
        digit,
        value;
    $target = e.currentTarget;
    digit = String.fromCharCode(e.which);
    if (!/^\d+$/.test(digit)) {
        return;
    }
    if (hasTextSelected($target)) {
        return;
    }
    value = ($target.value + digit).replace(/\D/g, '');
    card = cardFromNumber(value);
    if (card) {
        return value.length <= card.length[card.length.length - 1];
    }
    return value.length <= 16;
};
const setEvents = (el, cardType, cardNumberProp) => {
    el.onkeypress = (event) => {
        restrictNumeric(event);
        restrictCardNumber(event);
        formatCardInputNumber(event, cardNumberProp);
    };
    el.oninput = (event) => {
        reFormatCardNumber(event, cardNumberProp);
        setCardType(event, cardType);
    };
    el.onkeydown = event => formatBackCardNumber(event, cardNumberProp);
    el.onkeyup = (event) => {
        setCardType(event, cardType);
    };
    el.onpaste = event => reFormatCardNumber(event, cardNumberProp);
    el.onchange = (event) => {
        CatarseAnalytics.oneTimeEvent({ cat: 'contribution_finish', act: 'contribution_cc_edit' });
        reFormatCardNumber(event, cardNumberProp);
    };
};

const luhnCheck = (num) => {
    let digit,
        digits,
        i,
        len,
        odd,
        sum;
    odd = true;
    sum = 0;
    digits = (`${num}`).split('').reverse();
    for (i = 0, len = digits.length; i < len; i++) {
        digit = digits[i];
        digit = parseInt(digit, 10);
        if ((odd = !odd)) {
            digit *= 2;
        }
        if (digit > 9) {
            digit -= 9;
        }
        sum += digit;
    }
    return sum % 10 === 0;
};

const validateCardNumber = function (num) {
    let card,
        ref;
    num = (`${num}`).replace(/\s+|-/g, '');
    if (!/^\d+$/.test(num)) {
        return false;
    }
    card = cardFromNumber(num);
    if (!card) {
        return false;
    }
    return (ref = num.length, indexOf.call(card.length, ref) >= 0) && (card.luhn === false || luhnCheck(num));
};

const validateCardExpiry = function (month, year) {
    let currentTime,
        expiry,
        ref;
    if (typeof month === 'object' && 'month' in month) {
        ref = month, month = ref.month, year = ref.year;
    }
    if (!(month && year)) {
        return false;
    }
    month = String(month).trim();
    year = String(year).trim();
    if (!/^\d+$/.test(month)) {
        return false;
    }
    if (!/^\d+$/.test(year)) {
        return false;
    }
    if (!((month >= 1 && month <= 12))) {
        return false;
    }
    if (year.length === 2) {
        if (year < 70) {
            year = `20${year}`;
        } else {
            year = `19${year}`;
        }
    }
    if (year.length !== 4) {
        return false;
    }
    expiry = new Date(year, month);
    currentTime = new Date();
    expiry.setMonth(expiry.getMonth() - 1);
    expiry.setMonth(expiry.getMonth() + 1, 1);
    return expiry > currentTime;
};

const validateCardcvv = function (cvv, type) {
    let card,
        ref;
    cvv = String(cvv).trim();
    if (!/^\d+$/.test(cvv)) {
        return false;
    }
    card = cardFromType(type);
    if (card != null) {
        return ref = cvv.length, indexOf.call(card.cvvLength, ref) >= 0;
    }
    return cvv.length >= 3 && cvv.length <= 4;
};

const creditCardVM = {
    setEvents,
    validateCardNumber,
    validateCardcvv,
    validateCardExpiry
};

export default creditCardVM;
