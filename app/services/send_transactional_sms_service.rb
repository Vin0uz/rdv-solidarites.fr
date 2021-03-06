class NetsizeTimeout < StandardError; end

class NetsizeHttpError < StandardError; end

class NetsizeApiError < StandardError; end

class SendTransactionalSmsService < BaseService
  attr_reader :transactional_sms

  SENDER_NAME = "RdvSoli".freeze

  def initialize(transactional_sms)
    @transactional_sms = transactional_sms
  end

  def perform
    send("send_with_#{sms_provider}")
  end

  private

  def sms_provider
    if ENV["FORCE_SMS_PROVIDER"]
      ENV["FORCE_SMS_PROVIDER"].to_sym
    elsif Rails.env.production?
      :netsize
    else
      :debug_logger
    end
  end

  def send_with_send_in_blue
    SibApiV3Sdk::TransactionalSMSApi.new.send_transac_sms(
      SibApiV3Sdk::SendTransacSms.new(
        sender: SENDER_NAME,
        recipient: transactional_sms.phone_number_formatted,
        content: transactional_sms.content,
        tag: transactional_sms.tags.join(" ")
      )
    )
  end

  def send_with_netsize
    request = Typhoeus::Request.new(
      "https://europe.ipx.com/restapi/v1/sms/send",
      method: :post,
      userpwd: ENV["NETSIZE_API_USERPWD"],
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      timeout: 5,
      body: {
        destinationAddress: transactional_sms.phone_number_formatted,
        messageText: transactional_sms.content,
        originatingAddress: SENDER_NAME,
        originatorTON: 1,
        campaignName: transactional_sms.tags.join(" ").truncate(49),
      }
    )
    request.on_complete { netsize_on_complete(_1) }
    request.run
  end

  def netsize_on_complete(response)
    if response.success?
      parsed_res = JSON.parse(response.body)
      return if parsed_res["responseCode"].zero?

      ::Sentry.set_extras(parsed_res)
      raise NetsizeApiError, "HTTP 200, responseCode: #{parsed_res['responseCode']}, #{parsed_res['responseMessage']}"
    end

    raise NetsizeTimeout if response.timed_out?

    raise NetsizeHttpError, "code: #{response.code}, message: #{response.return_message}"
  end

  def send_with_debug_logger
    Rails.logger.debug("following SMS would have been sent in production environment: #{transactional_sms}")
  end
end
