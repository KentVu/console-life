use Socket;

#---------------基本設定---------------

#smtpサーバーのIPアドレス、またはホスト名
#$mailhost = '10.5.136.32';	#amimap
#$mailhost = '10.4.136.32';	#bimap
#$mailhost = '157.78.36.49';	#artemis

$mailhost = '10.5.134.204'; #jpavissmtp.tok.access-company.com

#送信元のメールアドレス
#$mailfrom = '';
#$mailfrom = 'shirou.asai@access-company.com';
#$mailfrom = 'arthur34@amimap.access.co.jp';
#$mailfrom = 'horii@access.co.jp';
#$mailfrom = '0sv025326mg3m7u@ezweb.ne.jp';
$mailfrom = 'vu_tran_kien@access.co.jp';
#送信先のメールアドレス


#$rcptto = 'test_hatirou20191114_2@au.com';
#$rcptto = '0pk2mb0d0635j2p@ezweb.ne.jp';
#$rcptto = '0pc025326ky472r@ezweb.ne.jp';
#$rcptto = '0sr2jy52726155n@ezweb.ne.jp';
#$rcptto = 'testaccess9996@ezweb.ne.jp';
#$rcptto = 'test_acs20171228_03@ezweb.ne.jp';
#$rcptto = '0vw41b322ky070w@ezweb.ne.jp';
#$rcptto = '20181104_0ty025326pj4z6w@au.com';
#$rcptto = 'test_saburou20171021@ezweb.ne.jp';
#$rcptto = '0rx425322mg3d9b@ezweb.ne.jp';
#$rcptto = '0ut2k-0t04f176c@ezweb.ne.jp';
#$rcptto = 'abcd-10294mgp@ezweb.ne.jp';
#$rcptto = '2017testadg_imap@au.com';
#$rcptto = '0nh2pj32025463b@ezweb.ne.jp';   # SAX
#$rcptto = '0nh326523034z2g@ezweb.ne.jp';    # ACC SHARP SHV44
#$rcptto = '0vw41b322ky070w@ezweb.ne.jp';   # Pixel 3a
#$rcptto = '0jh425322ky3j4v@ezweb.ne.jp';    # STF SCV39 Q
$rcptto = '0ve30352726464s@ezweb.ne.jp';    # TRO
#$rcptto = 'test0sh20200915_2@au.com';    # GEK-1


#送信順の設定(ファイル名でソートして正順で送信する場合は0、逆順で送信する場合は1としてください)
$reverse = 0;

#--------------------------------------

#定数的に使用する変数
$mailport = 25;
$crlf = "\r\n";
$in_addr = (gethostbyname($mailhost))[4];
$addr = sockaddr_in($mailport, $in_addr);
$proto = getprotobyname('tcp');

#コマンドライン引数が指定されていない場合のメッセージ
if (@ARGV == 0) {
	print 'メールソースのあるフォルダを指定してください',"\n";
	print 'ex)C:\ssmail>perl ssmail2.pl mailsrc', "\n";
	exit;
}

#ディレクトリ名の取得
$dir_name = shift @ARGV;
unless (-d $dir_name) {
	print "フォルダ $dir_name が見つかりません\n";
	exit;
}

#ディレクトリをオープンしてメールソースファイルリストを作成
opendir(DIR, $dir_name) or die "$!";
while ($filename = readdir(DIR)) {
	next if ($filename eq "." || $filename eq ".." || $filename =~ /^\.\w+|~$/);
	push(@mailsrclist, $filename);
}
closedir(DIR);

{my $tmprcpt = shift @ARGV;
if ($tmprcpt) {
	$rcptto =  $tmprcpt;
}
print "rcptto=$rcptto\n";
}

#ソケットを作成
socket(S, AF_INET, SOCK_STREAM, $proto) or die "socket: $!";

#ソケットをホストに接続する
connect(S, $addr) or die "Connect: $!";

#書き込み後毎回ソケットをフラッシュする
select (S); $| = 1; select (STDOUT);

#サーバー接続確認
die "EEROR: $!" unless &check_smtp_response(220,500);

#EHLOコマンドの送信
print S "EHLO $mailhost" . $crlf;
die "EEROR: $!" unless &check_smtp_response(250,501);

#$reverseの真偽によりメール送信方法選択
if ($reverse) {
	&sendmail_reverse;
}
else {
	&sendmail_normal;
}

#SMTPセッションを終了
print S "quit" . $crlf;
die "EEROR: $!" unless &check_smtp_response(221,500);

#ソケットをクローズして終了
close(S);
exit;

#smtp応答コードをチェックして成功なら1、失敗なら0を返す
sub check_smtp_response {
	my $result = 0;
	my $success_code = shift;
	my $error_code = shift;
	
	while (<S>) {
		if (/$success_code/i) {
			$result = 1;
			last;
		}
		if (/$error_code/i) {
			$result = 0;
			last;
		}
	}
	return($result);
}

#ファイル名でソートして正順で送信
sub sendmail_normal {
	for $mailsrc (sort @mailsrclist) {
		&send_mailfrom;
		&send_rcptto;	
		&send_data($mailsrc);
		sleep(1);
	}
}

#ファイル名でソートして逆順で送信
sub sendmail_reverse {
	for $mailsrc (reverse sort @mailsrclist) {
		&send_mailfrom;
		&send_rcptto;	
		&send_data($mailsrc);
		sleep(1);
	}
}

#mail fromコマンドを送信
sub send_mailfrom {
	print S "mail from: $mailfrom" . $crlf;
	die "EEROR: $!" unless &check_smtp_response(250,500);
}

#rcpt toコマンドを送信
sub send_rcptto {
	@recipients = split(/,/, $rcptto);
	for (@recipients) {
		print S "rcpt to: $_" . $crlf;
		die "EEROR: $!" unless &check_smtp_response(250,500);
	}
}

#dataコマンドを送信
sub send_data {
	my $mailsrc_name = shift;
	my $char;
	my $buf;

	#メールソースファイルをopenしてbuffer
	open(FILE, "$dir_name/$mailsrc_name") or die "$!";
	binmode(FILE);
	while (defined($char = getc(FILE))) {
		$buf .= $char;
	}
	close(FILE);
	
	#終末がCRLFでないときにCRLFを付加
	$buf = $buf . $crlf if ($buf =~ /[^$crlf]$/);
	
	print S "data" . $crlf;
	die "EEROR: $!" unless &check_smtp_response(354,500);
	print S $buf;
	print S "." . $crlf;
	die "EEROR: $!" unless &check_smtp_response(250,500);
	print "sent mail $mailsrc_name\n";
}

