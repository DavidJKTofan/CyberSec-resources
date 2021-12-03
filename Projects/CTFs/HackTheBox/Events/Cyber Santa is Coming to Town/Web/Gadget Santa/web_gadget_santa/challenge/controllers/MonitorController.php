<?php
class MonitorController
{
    public function index($router)
    {
        $command = isset($_GET['command']) ? $_GET['command'] : 'welcome';
        $monitor = new MonitorModel($command);
        return $router->view('index', ['output' => $monitor->getOutput()]);
    }
}