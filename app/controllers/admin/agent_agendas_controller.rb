# frozen_string_literal: true

class Admin::AgentAgendasController < AgentAuthController
  def show
    @agent = policy_scope(Agent).find(params[:id])
    authorize(AgentAgenda.new(agent: @agent, organisation: current_organisation))
    @status = params[:status]
    @organisation = current_organisation
    @selected_event_id = params[:selected_event_id]
    @date = params[:date].present? ? Date.parse(params[:date]) : nil
  end

  def toggle_display_saturdays
    @agent = current_agent
    authorize(@agent)
    @agent.update!(agent_role_params)
    redirect_to admin_organisation_agent_agenda_path(params.permit(:status, :selected_event_id, :date))
  end

  private

  def agent_role_params
    params.require(:agent).permit(:display_saturdays)
  end
end
