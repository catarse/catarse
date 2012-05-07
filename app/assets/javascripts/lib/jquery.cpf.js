/**
 Verifica se o CPF fornecido é válido segundo regras da Receita
 Federal. Não verifica se o CPF de fato existe e pertence à
 pessoa cujo nome foi informado.

 Regra de CPF válido:
 Dado um cpf 222.333.444-05, são separados os primeiros 9 dígitos,
 222333444.

 Em seguida multiplicamos os dígitos da direita para a esquerda
 primeiro por 2 depois por 3 etc.
 Ex:
 ---------------------------
  2  2  2  3  3  3  4  4  4  <- O números
 ---------------------------
  x  x  x  x  x  x  x  x  x  <- serão multiplicados
 ---------------------------
 10  9  8  7  6  5  4  3  2  <- começamos com 2 e incrementamos
 ---------------------------    em 1 cada número
 20 18 16 21 18 15 16 12  8  <- obtemos seus produtos
 ---------------------------

 Depois somamos seus produtos, que no caso acima resulta em 144:
 Obtemos o resto da soma dividida por 11, se o resto for menor que
 2, então o valor será 0 (zero), caso contrário o valor será 11
 menos o resto.
 Ex:
 144 % 11 = 1
 O resto é um, que é menor que 2, por isso o valor será 0.

 Agora juntamos o valor obtido aos números que serão novamente
 calculados.
 ------------------------------
  2  2  2  3  3  3  4  4  4  0  <- O números (mais o valor obtido)
 ------------------------------
  x  x  x  x  x  x  x  x  x  x  <- serão multiplicados
 ------------------------------
 11 10  9  8  7  6  5  4  3  2  <- começamos com 2 e incrementamos
 ------------------------------    em 1 cada número (agora até 11)
 22 20 18 24 21 18 20 16 12  0  <- obtemos seus produtos novamente
 ------------------------------

 A soma dos produtos agora será 171.

 Para obter o segundo valor, basta repetir a regra acima.
 Ex:
 171 % 11 = 6
 Como o resto é 6 (e maior ou igual a 2) o valor será
 11 menos 6, ou seja, 5.

 Obtidos os dois valores (neste caso, 0 e 5), basta compará-los com
 os dois últimos dígitos fornecidos para determinarmos a validade
 do CPF informado.
 NOTE: Não há nenhuma garantia de que o CPF existe de fato.
 */
jQuery.fn.isValidCPF = function() {
  var cpf, numbers, firstNumber, firstRemainder, firstResult,
  secondNumber, secondRemainder, secondResult,
  firstSum = 0, secondSum = 0,
  i, len, multiplier;
  
  var value = $(this).val()

  // A lista negra de CPF's
  var BLACK_LIST = [], i;
  for (i = 0; i < 10; ++i) {
      BLACK_LIST.push(Array(12).join(String(i)));
  }
  BLACK_LIST.push('12345678909');

  // Limpando o valor fornecido
  cpf = value.replace(/[_\-\.]/g,'');

  // Antes de qualquer coisa, o CPF não pode estar
  // na BLACK_LIST
  if (jQuery.inArray(cpf, BLACK_LIST) > -1) {
      return false;
  }

  // Os primeiros 9 números que serão calculados. Para fins
  // de comparação com os resultados, já são convertidos de
  // string para inteiros.
  numbers = cpf.split('');
  len = numbers.length;
  for(i = 0; i<len; i++) {
    numbers[i] = Number(numbers[i]);
  }
  
  secondNumber = numbers.pop();
  firstNumber = numbers.pop();

  // Obtendo soma dos produtos dos números
  for (i = 0, multiplier = 10; i < 9; ++i, --multiplier) {
      firstSum += numbers[i] * multiplier;
  }

  // Somamos os produtos e obtemos o resto de sua divisão por 11.
  firstRemainder = firstSum % 11;

  // Se o resto for menor que 2, o primeiro número será 0, caso
  // contrário, será a diferença de 11 menos o resto.
  firstResult = firstRemainder < 2 ? 0 : 11 - firstRemainder;

  // O primeiro resultado será incluído nos números a serem
  // calculados para o segundo resultado.
  numbers.push(firstResult);

  // Repetindo o processo de soma dos produtos, com o primeiro
  // resultado incluído.
  for (i = 0, multiplier = 11; i < 10; ++i, --multiplier) {
      secondSum += numbers[i] * multiplier;
  }

  // O cáculo para determinar o segundo resultado é o mesmo.
  secondRemainder = secondSum % 11;
  secondResult = secondRemainder < 2 ? 0 : 11 - secondRemainder;

  // Agora é só comparar os resultados com os dois últimos
  // dígitos fornecidos.
  return firstNumber === firstResult && secondNumber === secondResult;
}
