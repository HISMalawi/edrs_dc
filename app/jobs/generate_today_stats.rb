class GenerateTodayStats
  include SuckerPunch::Job
    workers 1
    def perform
        `rake edrs:generate_today_stats`
        if Rails.env == "development"
          SuckerPunch.logger.info "Genearte stats"
        end

        GenerateTodayStats.perform_in(600)
    end
end