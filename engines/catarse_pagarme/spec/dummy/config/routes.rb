Rails.application.routes.draw do
  mount CatarsePagarme::Engine => "/", as: :catarse_pagarme
end
