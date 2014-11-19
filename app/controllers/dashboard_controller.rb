class DashboardController < ApplicationController

  before_filter :authenticate_admin!

  layout 'application'

  def index
    # TODO: Refactor this to do the report the new way, w/o reply_tweet_admin_id logic

=begin
    if current_admin.has_any_role?(:deleter,:responder)

      # display the report for the deleter / responder depending upon who logged on
      pay_date = Date.parse(Time.now.strftime('%Y-%m-%d')).to_s

      @pay_day_reports = Report.payday_report( pay_date, current_admin.id )

      # beg_date = Time.now - 21.days
      # @deletes  = Conversation.where(admin_id:              current_admin).where("updated_at >= ?", beg_date).where.not( fetched_at: nil)
      # @replies  = Conversation.where(reply_tweet_admin_id:  current_admin).where("updated_at >= ?", beg_date).where.not( fetched_at: nil)

      # inspired by: http://thepugautomatic.com/2014/08/union-with-active-record/
      # sql     = Admin.connection.unprepared_statement{"((#{Admin.with_role(:superadmin).to_sql}) UNION (#{Admin.with_role(:admin).to_sql})) AS admins"}
      # @conversations = @deletes + @replies
    end
=end

  end

end
