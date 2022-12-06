# frozen_string_literal: true

module RdvsUser::Creatable
  extend ActiveSupport::Concern

  def create_and_notify(author)
    RdvsUser.transaction do
      empty_rdv_from_relatives
      if save
        notify_create!(author)
        true
      else
        false
      end
    end
  end

  def rdv_user_token
    # For user invited with tokens, nil default for not invited users
    @notifier&.rdv_users_tokens_by_user_id&.fetch(user.id, nil)
  end

  private

  def empty_rdv_from_relatives
    # Empty self_and_relatives rdvs_users (at the moment, only one member by family), no callbacks, no notifications
    rdv.rdvs_users.where(user: user.responsible&.self_and_relatives_and_responsible).delete_all
  end

  def notify_create!(author)
    @notifier = Notifiers::RdvCreated.new(rdv, author)
    @notifier.perform
    # we re-enable the webhooks that we deactivated during the notification process
    rdv.skip_webhooks = false
  end
end
