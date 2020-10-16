beforeAll(function() {
  TranslationsFactory = function(attrs) {
      window.I18n.defaultLocale = "pt";
      window.I18n.locale = "pt";
      I18n.translations = attrs;
  };
  TranslationsFactory({
      pt: {
          projects: {
              index: {
                  explore_categories: {
                      10: {
                          link: 'external_link'
                      }
                  }
              },
              faq: {
                  aon: {
                      description: 'faqBox description',
                      questions: {
                          1: {
                              question: 'question_1',
                              answer: 'answer_1'
                          },
                          2: {
                              question: 'question_1',
                              answer: 'answer_1'
                          },
                          3: {
                              question: 'question_1',
                              answer: 'answer_1'
                          }
                      }
                  }
              }
          }
      }
  })
});
