module Locomotive
  class SessionsController < ::Devise::SessionsController

    include Locomotive::Concerns::SslController
    include Locomotive::Concerns::RedirectToMainHostController
    include Locomotive::Concerns::WithinSiteController

    within_site_only_if_existing true # Note: do not validate the membership

    layout '/locomotive/layouts/account'

    before_filter :set_locale

    helper Locomotive::BaseHelper

    private

    def after_sign_in_path_for(resource)
      cn_site = resource.sites.first
      if cn_site.memberships.where(account_id:resource.id).first.normal?
        content_type = cn_site.content_types.where(slug: 'faculities').first
        own_entry = content_type.entries.where(email:current_locomotive_account.email).first
        edit_content_entry_path(cn_site, content_type.slug, own_entry)
      else
        current_site? ? dashboard_path(current_site) : sites_path
      end

    end

    def after_sign_out_path_for(resource)
      new_locomotive_account_session_path
    end

    def set_locale
      if current_site?
        I18n.locale = current_site.accounts.first.locale
      end
    end

  end
end
