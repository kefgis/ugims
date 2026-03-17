<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Maintenance Calendar</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <!-- FullCalendar CSS -->
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
    <style>
        #calendar {
            max-width: 1100px;
            margin: 40px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .filters {
            margin: 20px auto;
            max-width: 1100px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>Maintenance Calendar</h2>
        <div>
            <a href="dashboard.php">Dashboard</a>
            <a href="logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <div class="filters">
            <select id="zoneFilter">
                <option value="">All Zones</option>
                <?php
                require_once '../api/config/database.php';
                $db = (new Database())->getConnection();
                $zones = $db->query("SELECT zone_id, zone_name FROM ugims_maintenance_zone")->fetchAll();
                foreach ($zones as $z) {
                    echo "<option value=\"{$z['zone_id']}\">".htmlspecialchars($z['zone_name'])."</option>";
                }
                ?>
            </select>
            <select id="teamFilter">
                <option value="">All Teams</option>
                <?php
                $teams = $db->query("SELECT team_id, team_name FROM ugims_team")->fetchAll();
                foreach ($teams as $t) {
                    echo "<option value=\"{$t['team_id']}\">".htmlspecialchars($t['team_name'])."</option>";
                }
                ?>
            </select>
            <button id="applyFilters">Apply</button>
        </div>
        <div id="calendar"></div>
    </div>

    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                events: function(fetchInfo, successCallback, failureCallback) {
                    let url = '../api/get_activities_calendar.php?start=' + fetchInfo.startStr + '&end=' + fetchInfo.endStr;
                    let zone = document.getElementById('zoneFilter').value;
                    let team = document.getElementById('teamFilter').value;
                    if (zone) url += '&zone=' + zone;
                    if (team) url += '&team=' + team;

                    fetch(url)
                        .then(response => response.json())
                        .then(data => successCallback(data))
                        .catch(error => failureCallback(error));
                },
                eventClick: function(info) {
                    if (info.event.url) {
                        window.open(info.event.url, '_blank');
                        info.jsEvent.preventDefault();
                    }
                }
            });
            calendar.render();

            document.getElementById('applyFilters').addEventListener('click', function() {
                calendar.refetchEvents();
            });
        });
    </script>
</body>
</html>