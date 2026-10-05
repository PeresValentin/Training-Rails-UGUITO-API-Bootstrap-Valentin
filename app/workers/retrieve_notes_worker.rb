class RetrieveNotesWorker < BaseUserWorker
  private

  def initialize_variables(params)
    @params = params
  end

  def perform_args
    [@params]
  end

  def service
    :retrieve_notes
  end

  def attempt
    "retrieving notes with params: #{@params}"
  end
end
