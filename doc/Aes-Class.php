class QuickBooks_Encryption_AES
	{
	static function encrypt($key, $plain, $salt = null)
		{
		if (is_null($salt))
			{
			$salt = $this->salt();
			}
		
		$plain = serialize(array( $plain, $salt ));
		
		$crypt = mcrypt_module_open('rijndael-256', '', 'ofb', '');

		if (false !== stripos(PHP_OS, 'win') and 
			version_compare(PHP_VERSION, '5.3.0')  == -1) 
			{
			$iv = mcrypt_create_iv(mcrypt_enc_get_iv_size($crypt), MCRYPT_RAND);	
			}
		else
			{
			$iv = mcrypt_create_iv(mcrypt_enc_get_iv_size($crypt), MCRYPT_DEV_URANDOM);
			}

		$ks = mcrypt_enc_get_key_size($crypt);
		$key = substr(md5($key), 0, $ks);
		
		mcrypt_generic_init($crypt, $key, $iv);
		$encrypted = base64_encode($iv . mcrypt_generic($crypt, $plain));
		mcrypt_generic_deinit($crypt);
		mcrypt_module_close($crypt);
		
		return $encrypted;
		}
	
	static function decrypt($key, $encrypted)
		{
		$crypt = mcrypt_module_open('rijndael-256', '', 'ofb', '');
		$iv_size = mcrypt_enc_get_iv_size($crypt);
		$ks = mcrypt_enc_get_key_size($crypt);
		$key = substr(md5($key), 0, $ks);
		
		//print('before base64 [' . $encrypted . ']' . '<br />');
		
		$encrypted = base64_decode($encrypted);
		
		//print('given key was: ' . $key);
		//print('iv size: ' . $iv_size);
		
		//print('decrypting [' . $encrypted . ']' . '<br />');
		
		mcrypt_generic_init($crypt, $key, substr($encrypted, 0, $iv_size));
		$decrypted = trim(mdecrypt_generic($crypt, substr($encrypted, $iv_size)));
		mcrypt_generic_deinit($crypt);
		mcrypt_module_close($crypt);
		
		//print('decrypted: [[**(' . $salt . ')');
		//print_r($decrypted);
		//print('**]]');
			
		$tmp = unserialize($decrypted);
		$decrypted = current($tmp);
		
		return $decrypted;
		}
	
	static function salt()
		{
		$tmp = array_merge(range('a', 'z'), range('A', 'Z'), range(0, 9));
		shuffle($tmp);
			
		$salt = substr(implode('', $tmp), 0, 32);
			
		return $salt;
		}	
	}
