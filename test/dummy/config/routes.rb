Dummy::Application.routes.draw do
  constraints SubdomainSite::Constraint.new do
    get '/', to: 'sites#show', as: 'site'
    resources 'post', only: :show
  end
  root 'sites#index'
end
