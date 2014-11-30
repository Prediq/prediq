class QuickbooksController < ApplicationController

  def authenticate
    callback = 'http://localhost:3003/oauth_callback'
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    token = at.token
    secret = at.secret
    realm_id = params['realmId']
    # Create quickbooks auth object to store credentials if user does not already have one
    quickbooks_auth = current_user.quickbooks_auth || QuickbooksAuth.create!(user_id: current_user.id)
    quickbooks_auth.update!(
      token: token,
      secret: secret,
      realm_id: realm_id
    )
    # store the token, secret & RealmID somewhere for this user, you will need all 3 to work with Quickbooks-Ruby
    redirect_to '/quickbooks_success', notice: "Your QuickBooks account has been successfully linked."
  end
  
  def quickbooks_success
    
  end
end
