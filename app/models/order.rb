class Order < ApplicationRecord

validates :order_id , uniqueness: true


def self.send_delivery_data(data)
    delivery = data["fields_values"].select{ |field| field['name'] == 'smartpost'}[0]['value']
    est_terminal_id = delivery.include?('EE(APT)') ? delivery.split('---')[1].remove('(').remove(')') : ''
    fin_postal_code = delivery.include?('FIN(PO)') ? delivery.split('---')[1].remove('(').remove(')') : ''
    fin_postal_code_address = delivery.include?('FIN(PO)') ? delivery.split('---').last.split(',').last.strip : ''
    fin_terminal_code = delivery.include?('FIN(APT)') ? delivery.split('---')[1].remove('(').remove(')') : ''
    fin_terminal_code_address = delivery.include?('FIN(APT)') ? delivery.split('---').last.split(',').last.strip : ''
    if delivery.include?('EE(APT)')
    data = {
      order_number: data["number"],
      client_name: data["client"]['name']+data["client"]['surname'],
      client_phone: data["client"]['phone'],
      client_email: data["client"]['email'],
      est_terminal_id: est_terminal_id
    }
    end
    if delivery.include?('FIN(APT)')
      url_xml = "http://iseteenindus.smartpost.ee/api/?request=destinations&country=FI&type=APT"
      resp = RestClient.get(url_xml)
      resp_data = Nokogiri::XML(resp)
      puts "fin_terminal_code "+fin_terminal_code.to_s
      puts "fin_terminal_code_address "+fin_terminal_code_address.to_s
      search_routing_code = resp_data.xpath("//item").select{|i| i.xpath('postalcode').text == fin_terminal_code && i.xpath('address').text == fin_terminal_code_address }[0].xpath('routingcode').text

      data = {
        order_number: data["number"],
        client_name: data["client"]['name']+data["client"]['surname'],
        client_phone: data["client"]['phone'],
        client_email: data["client"]['email'],
        postal_code: fin_terminal_code,
        routing_code: search_routing_code
      }
    end
    if delivery.include?('FIN(PO)')
      data = {
        order_number: data["number"],
        client_name: data["client"]['name']+data["client"]['surname'],
        client_phone: data["client"]['phone'],
        client_email: data["client"]['email'],
        postal_code: fin_postal_code,
        routing_code: '3200'
      }
    end

    Order.create_shipment_smartpost(data)
end

def self.create_shipment_smartpost(data)
  order_number = data[:order_number].present? ? data[:order_number] : '12'
  client_name = data[:client_name].present? ? data[:client_name] : 'test'
  client_phone = data[:client_phone].present? ? data[:client_phone] : '21080435'
  client_email = data[:client_email].present? ? data[:client_email] : 'test@mail.ru'
  est_terminal_id = data[:est_terminal_id].present? ? data[:est_terminal_id] : ''
  postal_code = data[:postal_code].present? ? data[:postal_code] : ''
  routing_code = data[:routing_code].present? ? data[:routing_code] : ''

  add_url = "http://iseteenindus.smartpost.ee/api/?request=shipment"
  send_data_xml = '<orders>
	<authentication>
		<user>'+Rails.application.secrets.smartpost_user+'</user>
		<password>'+Rails.application.secrets.smartpost_password+'</password>
	</authentication>
	<report>
		<email></email>
	</report>
	<item>
		<barcode></barcode>
		<reference>'+order_number.to_s+'</reference>
		<content>goods</content>
		<orderparent>string</orderparent>
		<weight>0.5</weight>
		<size>11</size>
		<sender>
			<name></name>
			<phone></phone>
			<email></email>
			<cash></cash>
			<account></account>
		</sender>
		<recipient>
			<name>'+client_name+'</name>
			<phone>'+client_phone+'</phone>
			<email>'+client_email+'</email>
			<cash></cash>
			<idcode></idcode>
		</recipient>
		<destination>
			<place_id>'+est_terminal_id+'</place_id>
			<postalcode>'+postal_code+'</postalcode>
			<routingcode>'+routing_code+'</routingcode>
			<street></street>
			<house></house>
			<apartment></apartment>
			<city></city>
			<country></country>
			<details></details>
			<timewindow></timewindow>
		</destination>
		<additionalservices>
			<express></express>
			<idcheck></idcheck>
			<agecheck></agecheck>
			<notifyemail></notifyemail>
			<notifyphone></notifyphone>
			<paidbyrecipient></paidbyrecipient>
		</additionalservices>
	</item>
</orders>'
puts send_data_xml
  RestClient.post( add_url, send_data_xml, accept: :xml, content_type: "'application/xml") { |response, request, result, &block|
    case response.code
    when 200
      puts 'создали отправление'
      resp_data = Nokogiri::XML(response)
      barcode = resp_data.xpath("//item/barcode").text
      puts barcode
    when 400
      puts "error 400"
      puts response.to_s
    when 404
      puts 'error 404'
      break
    when 503
      sleep 1
      puts 'sleep 1 error 503'
    else
      response.return!(&block)
      sleep 0.3
    end
    }

end


end
