require 'simple_amqp_server'

class MedusaFixityServer < SimpleAmqpServer::Base

  def initialize(args = {})
    super(args)
  end

  def handle_file_fixity_request(interaction)
    
  end

end
