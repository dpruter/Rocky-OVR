class BrandingUpdateRequest
  STATUS = OpenStruct.new(not_found: "not_found", open: "open", rejected: "rejected", done: "done").freeze

  ALLOWED_TRANSITIONS = {
      STATUS.not_found => [STATUS.open],
      STATUS.open => [STATUS.not_found, STATUS.done, STATUS.rejected],
      STATUS.done => [STATUS.open],
      STATUS.rejected => [STATUS.open]
  }

  def initialize(partner)
    @partner = partner
    request = @partner.branding_update_request
    @data = request.status.nil? ? default_request_data : request
  end

  def status
    @data.status
  end

  def date
    @data.date.try(:to_s) || ""
  end

  def open
    update_status(STATUS.open)
  end

  def delete
    update_status(STATUS.not_found)
  end

  def done
    update_status(STATUS.done)
  end

  def reject
    update_status(STATUS.rejected)
  end

  def can_be_opened
    can_be STATUS.open
  end

  def can_be_done
    can_be STATUS.done
  end

  def can_be_closed
    can_be STATUS.not_found
  end

  private

  def default_request_data
    OpenStruct.new(
        "status" => STATUS.not_found,
        "date" => nil
    )
  end

  def update_status(status)
    raise "Invalid operation" unless can_be(status)
    @data.status = status
    @data.date = Date.today
    save!
  end

  def can_be(status)
    !!ALLOWED_TRANSITIONS[@data.status].find { |v| v == status }
  end

  def save!
    @partner.update_attributes(branding_update_request: @data)
  end
end