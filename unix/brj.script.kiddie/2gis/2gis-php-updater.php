static $last_len = 0;

if(file_exists("stat.json"))
    $bases_info = json_decode(file_get_contents("stat.json"), 1);

$ch = curl_init('http://s1.update.2gis.com/ver3/infolist?platform=win32&include_infofiles');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$data = curl_exec($ch);
curl_close($ch);

$pakages = new SimpleXmlElement($data);

foreach($pakages->package As $package)
{
    $data = base64_decode($package);
    $n = strpos($data, "<package_info");
    $pak = substr($data, $n);
    $pakxml = new SimpleXmlElement($pak);

    $msifilename = $pakxml->file_name;

    $dgdatfilename = str_ireplace(array(".msi","2gis"),"",$msifilename);
    list($dgdatfilename,) = explode("-",$dgdatfilename);
    $dgdatfilename .= ".dgdat";

    $filenamez = $pakxml->file_name."z";
    $msiz_size = $pakxml->data_size;

    $title = (string)$pakxml->title;
    $issue = (string)$bases_info[$title][issue];

    if(stripos($pakxml->file_name,"2gisdata")===false)
        continue;

    if($issue!=$pakxml->issue || !file_exists($dgdatfilename))
    {
        if(!file_exists($msifilename) ||
            (file_exists($msifilename) && filesize($msifilename)!=$pakxml->plain_size))
        {
            if(file_exists($filenamez) && filesize($filenamez)!=$msiz_size)
                unlink($filenamez);
        
            if(!file_exists($filenamez))
            {
                $last_len = 0;
                echo "Download ".$filenamez."... ";
                $fp = fopen($filenamez, 'w');
                $url = "http://s1.update.2gis.com/ver3/download/".$filenamez;
                $ch = curl_init($url);
            	curl_setopt($ch, CURLOPT_FILE, $fp);
                curl_setopt($ch, CURLOPT_PROGRESSFUNCTION, 'progress');
                curl_setopt($ch, CURLOPT_NOPROGRESS, false); // needed to make progress function work
                $data = curl_exec($ch);
                curl_close($ch);
        
                fclose($fp);
        
                echo "\n";
            }
        
            if(file_exists($filenamez))
            {
                $data = file_get_contents($filenamez);
                $decoded = gzdecode($data);
                if($decoded===FALSE)
                    die("Stop: ungzip error.\n");
                file_put_contents($msifilename,$decoded);
                if($pakxml->plain_size!=filesize($msifilename))
                    die("Stop: plain_size mismatch.\n");
                unlink($filenamez);
            }
        }
    
        $cmd = "7z l -slt ".$msifilename;
        exec($cmd, $output, $return_value);
        $found = 0;
        foreach($output As $line) {
            if(stristr($line, "dgdat")==TRUE) {
                $tofile = str_replace("Path = ","", $line);
                $found = 1;
            }
        }
    
        if($found == 0)
            die("!!!\n");
    
        $cmd = "7z x \"$msifilename\" ".$tofile;
        exec($cmd, $output, $return_value);
        rename($tofile,$dgdatfilename);

        unlink($msifilename);
    }

    $bases_info[$title]["issue"] = (string)$pakxml->issue;
    $bases_info[$title]["issue_date"] = (string)$pakxml->issue_date;
    file_put_contents("stat.json", json_encode($bases_info,JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT));
}

function progress($download_size, $downloaded, $upload_size, $uploaded)
{
    global $last_len;

    if($download_size > 0) {
        echo str_repeat(Chr(8), $last_len);
        $str = number_format(($downloaded / $download_size * 100), 1)."%";
        $last_len = strlen($str);
        echo $str;
    }

    ob_flush();
    flush();
}
