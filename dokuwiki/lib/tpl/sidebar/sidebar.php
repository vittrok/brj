<?php

// recursive function to establish best sidebar file to be used
function getSidebarFN($ns, $file) {
 
  // check for wiki page = $ns:$file (or $file where no namespace)
  $nsFile = ($ns) ? "$ns:$file" : $file;
  if (file_exists(wikiFN($nsFile))) return wikiFN($nsFile);
  
  // remove deepest namespace level and call function recursively
  
  // no namespace left, exit with no file found	
  if (!$ns) return '';
  
  $i = strrpos($ns, ":");
  $ns = ($i) ? substr($ns, 0, $i) : false;	
  return getSidebarFN($ns, $file);
}

/**
 * Returns xhtml for a virtual local sidebar file
 * based on instructions from a master file
 *
 * Uses and creates a cachefile
 *
 * @author Jan Decaluwe <jan@jandecaluwe.com>
 * by adapting the p_cached_xhtml function in dokuwiki
 *
 */
function p_sidebar_cached_xhtml($localFile, $masterFile){
  global $conf;
  $cache  = getCacheName($localFile.$_SERVER['HTTP_HOST'].$_SERVER['SERVER_PORT'],'.xhtml');
  $purge  = $conf['cachedir'].'/purgefile';
  // check if cache can be used
  $cachetime = @filemtime($cache); // 0 if not exists

  if( @file_exists($masterFile)                                       // does the source exist
      && $cachetime > @filemtime($masterFile)                         // cache is fresh
      && ((time() - $cachetime) < $conf['cachetime'])                 // and is cachefile young enough
      && !isset($_REQUEST['purge'])                                   // no purge param was set
      && ($cachetime > @filemtime($purge))                            // and newer than the purgefile
      && ($cachetime > @filemtime(DOKU_INC.'conf/dokuwiki.php'))      // newer than the config file
      && ($cachetime > @filemtime(DOKU_INC.'conf/local.php'))         // newer than the local config file
      && ($cachetime > @filemtime(DOKU_INC.'inc/parser/xhtml.php'))   // newer than the renderer
      && ($cachetime > @filemtime(DOKU_INC.'inc/parser/parser.php'))  // newer than the parser
      && ($cachetime > @filemtime(DOKU_INC.'inc/parser/handler.php')))// newer than the handler
  {
    //well then use the cache
    $parsed = io_readfile($cache);
    $parsed .= "\n<!-- cachefile $cache used -->\n";
  }else{
    $parsed = p_render('xhtml', p_cached_instructions($masterFile),$info); //try to use cached instructions

    if($info['cache']){
      io_saveFile($cache,$parsed); //save cachefile
      $parsed .= "\n<!-- no cachefile used, but created -->\n";
    }else{
      @unlink($cache); //try to delete cachefile
      $parsed .= "\n<!-- no cachefile used, caching forbidden -->\n";
    }
  }

  return $parsed;
}
 
function html_sidebar() {
  global $ID;
  global $ACT;

  if ($ACT != 'show') return '';
  
  // determine master sidebar file
  $masterFile = getSidebarFN(getNS($ID), 'sidebar');
   
  // open sidebar <div>
  echo("<div id='sidebar'>");
  
  // determine what to display
  if ($masterFile) {
    // virtual hidden local sidebar filename
    $fn = wikiFN($ID.'_sidebar');
    $localFile = dirname($fn).'/_'.basename($fn);
    print p_sidebar_cached_xhtml($localFile, $masterFile);
  }
  else {
    html_index('.');
  }

  // brj
  include(dirname(__FILE__).'/ya5.php');
  
  // close sidebar <div>
  echo("</div>");

}

?>