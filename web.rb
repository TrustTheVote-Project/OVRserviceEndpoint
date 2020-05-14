require 'sinatra'

post '/SureOVRWebAPI/api/ovr' do
  sleep 1
  
  request.body.rewind
  a = request.body.read
  request_payload = JSON.parse a
  
  
  @request_xml = request_payload["ApplicationData"]
  Post.create!(xml_request: @request_xml, query_string: params)
  is_error = @request_xml.to_s.downcase =~ /<firstname>error<\/firstname>/
  if is_error
    raise "Error"
  end
  
  #<p>To trigger an empty application ID, use EMPTY as the first name.</p>
  is_empty = @request_xml.to_s.downcase =~ /<firstname>empty<\/firstname>/
  if is_empty
    return "<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE></APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR></ERROR></RESPONSE>"
  end
  #<p>To trigger a malformed response, use FORMAT as the first name.</p>
  is_bad_format = @request_xml.to_s.downcase =~ /<firstname>format<\/firstname>/
  if is_bad_format
    return "<RESPONSE>"
  end
  
  #<p>To trigger an timeout response, use TIMEOUT as the first name.</p>
  is_timeout = @request_xml.to_s.downcase =~ /<firstname>timeout<\/firstname>/
  if is_timeout
    sleep(130)
    return "<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE></APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR></ERROR></RESPONSE>"
  end
  
  
  
  is_signature_error = @request_xml =~ /<FirstName>VR_WAPI_Invalidsignaturecontrast<\/FirstName>/
  if !is_signature_error.nil? 
    has_signature = @request_xml =~ /<signatureimage>\s*[^\s]+\s*<\/signatureimage>/
    if has_signature.nil?
      return "<RESPONSE><APPLICATIONID>010101</APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR></ERROR></RESPONSE>"
    end
    error_string = $1 || "There was an error"
    return "<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR>#{error_string}</ERROR></RESPONSE>"
  end
  
  is_specific_error = @request_xml =~ /<FirstName>(VR_WAPI_.+)<\/FirstName>/
  if is_specific_error
    error_string = $1 || "There was an error"
    return "<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR>#{error_string}</ERROR></RESPONSE>"
  end
  return "<RESPONSE><APPLICATIONID>010101</APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR></ERROR></RESPONSE>"
end


get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end