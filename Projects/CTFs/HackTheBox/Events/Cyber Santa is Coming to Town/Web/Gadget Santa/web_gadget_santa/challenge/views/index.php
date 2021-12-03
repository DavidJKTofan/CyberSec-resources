<html>
<head>
  <meta name='author' content='rayhan0x01, makelaris, makelarisjr'>
  <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
  <title>Gadget Santa</title>
  <link rel='stylesheet' href='/static/css/main.css' />
  <link rel='preconnect' href='//fonts.gstatic.com'>
  <link link='preload' href='//fonts.googleapis.com/css2?family=Press+Start+2P&display=swap' rel='stylesheet'>
  <link rel='icon' href='/static/images/favicon.png' />
</head>
<body>
<div id='mainwrapper'>
  <img id='topcandy' src='/static/images/cane2.png'> 
  <img id='ctree' src='/static/images/ctree.png'> 
  <img id='chat' src='/static/images/chat.png'> 
  <img id='calender' src='/static/images/calender.png'> 
  <div class='consume_relative'>
    <img src='/static/images/fireplace.png' id='fireplace'>
    <div id='deviceBody'>
        <div class='consume_relative'>
          <div id='left_panel'>
            <div class='consume_relative'>
               <ul id='cmd_list'>
                <a href="/?command=ups_status"><li>UPS Status</li></a>
                <a href="/?command=restart_ups"><li>Restart UPS</li></a>
                <a href="/?command=list_processes"><li>List Processes</li></a>
                <a href="/?command=list_ram"><li>List Ram</li></a>
                <a href="/?command=list_connections"><li>List Connections</li></a>
                <a href="/?command=list_storage"><li>List Storage</li></a>
              </ul>
              <img id='ckeyring' src='/static/images/ckeyring.png'>
              <img id='cwheel' src='/static/images/cwheel.png'>
            </div>
          </div>
          <div id='right_console'>
            <div class='consume_relative'>
              <pre><?php echo htmlspecialchars($output); ?></pre>
            </div>
          </div>
          <img id='keyboard' src='/static/images/keyboard.jpg'>
          <div id='bottom_area'></div>
        </div>
    </div>
    <div id='right_grid'></div>
    <div id='generator_switch'></div>
  </div>
</div>
</body>
</html>