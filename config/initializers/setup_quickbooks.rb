QB_KEY = "qyprda7A7mXjuUJJ8Zr9q6uOibccoB"
QB_SECRET = "EeVlrvwviyGoXBf8kkEp9V8h9kVYXr3QWEv4VGo9"

$qb_oauth_consumer = OAuth::Consumer.new(QB_KEY, QB_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})