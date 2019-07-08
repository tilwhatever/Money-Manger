<?php
    /* ----- get http body and prepare result ----- */ 
    $input = file_get_contents("php://input");
    $query = json_decode($input, TRUE);
    header("Content-Type: application/json");

    /* ----- connect to database ----- */
    //$pdo = new PDO("mysql:host=localhost;dbname=money-manager", "root", "");
    $con = new mysqli("localhost", "tilpo", "..", "money-manager");
    if ($con->connect_errno) {
        $result = (object)array();
        $result->data = "err";
    }

    /* ----- get http action ----- */
    switch ($query["request"]["query"]) {
        case "getIds":
            echo getIds();
            return;
        case "getActionsInMonth":
            echo getActionsInMonth($con,
                $query["request"]["data"]["init"],
                $query["request"]["data"]["year"],
                $query["request"]["data"]["month"]
            );
            return;
        case "addAction":
            echo addAction($con, 
                $query["request"]["data"]["description"],
                $query["request"]["data"]["amount"],
                $query["request"]["data"]["amountCent"],
                $query["request"]["data"]["day"],
                $query["request"]["data"]["month"],
                $query["request"]["data"]["year"],
                $query["request"]["data"]["action"],
                $query["request"]["data"]["category"]
            );
            return;
        case "editAction":
            echo editAction($con, 
                $query["request"]["data"]["id"],
                $query["request"]["data"]["description"],
                $query["request"]["data"]["amount"],
                $query["request"]["data"]["amountCent"],
                $query["request"]["data"]["day"],
                $query["request"]["data"]["month"],
                $query["request"]["data"]["year"],
                $query["request"]["data"]["action"],
                $query["request"]["data"]["category"]
            );
            return;
        case "getAction":
            echo getAction($con, $query["request"]["data"]["id"]);
            return;
        case "removeAction":
            echo removeAction($con, 
                $query["request"]["data"]["id"]
            );
            return;
        case "getCategories":
            echo getCategories($con);
            return;
        case "addCategory":
            echo addCategory($con, $query["request"]["data"]["category"]);
            return;
        case "removeCategory":
            echo removeCategory($con, $query["request"]["data"]["category"]);
            return;
    }

    /* ----- functions ----- */
    function getIds() {
        $result = (object)array();
        $result->data = "works";
        return json_encode($result);
    }

    function getAction($con, $id) {
        $result = (object)array();
        $result->data = (object)array();

        $sql = "
            SELECT actions.id, description, amount, amountCent, day, month, year, action, categories.category FROM actions LEFT JOIN categories ON actions.category = categories.id 
            WHERE actions.id = ?
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("i", $id);
        $sql->execute();
        $sql = $sql->get_result();
        while ($row = $sql->fetch_object()) {
            $row = (array)$row;
            $result->data->id = $row["id"];
            $result->data->description = $row["description"];
            $result->data->amount = $row["amount"];
            $result->data->amountCent = $row["amountCent"];
            $result->data->category = $row["category"];
            $result->data->actionType = $row["action"];
            $result->data->date = (object)array();
            $result->data->date->day = $row["day"];
            $result->data->date->month = $row["month"];
            $result->data->date->year = $row["year"];
        }

        return json_encode($result);
    }

    function getActionsInMonth($con, $init, $year, $month) {
        $result = (object)array();
        $result->data = (object)array();
        $result->data->actions = array();
        
        if ($init == "init") {
            $year = date("Y");
            $month = date("n");
        }

        $result->data->currentDate = (object)array();
        $result->data->currentDate->day = 1;
        $result->data->currentDate->month = intval($month);
        $result->data->currentDate->year = intval($year);

        $sql = "
            SELECT actions.id, description, amount, amountCent, day, month, year, action, categories.category FROM actions LEFT JOIN categories ON actions.category = categories.id 
            WHERE year = ? and month = ? ORDER BY year, month, day ASC
        ";
        
        $sql = $con->prepare($sql);
        $sql->bind_param("ii", intval($year), intval($month));
        $sql->execute();
        $sql = $sql->get_result();
        while ($row = $sql->fetch_object()) {
            $row = (array)$row;
            $entry = (object)array();
            $entry->id = $row["id"];
            $entry->description = $row["description"];
            $entry->amount = $row["amount"];
            $entry->amountCent = $row["amountCent"];
            $entry->category = $row["category"];
            $entry->actionType = $row["action"];
            $entry->date = (object)array();
            $entry->date->day = $row["day"];
            $entry->date->month = $row["month"];
            $entry->date->year = $row["year"];

            array_push($result->data->actions, $entry);
        }

        return json_encode($result);
    }

    function addAction($con, $description, $amount, $amountCent, $day, $month, $year, $action, $category) {
        $result = (object)array();
        $result->data = (object)array();
        
        $sql = "
            SELECT (id) FROM categories WHERE category = ?
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("s", $category);
        $sql->execute();
        $sql = $sql->get_result();
        $row = $sql->fetch_object();
        $row = (array)$row;

        $sql = "
            INSERT INTO actions (description, amount, amountCent, day, month, year, action, category)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ";
        $sql = $con->prepare($sql);
        $sql->bind_param("siiiiiii", $description, $amount, $amountCent, $day, $month, $year, $action, $row["id"]);

        if ($sql->execute() === TRUE) {
            $result->data->result = TRUE;
            $result->data->error = "";
        } else {
            $result->data->result = FALSE;
            $result->data->error = $sql->error;
        }

        
        return json_encode($result);
    }

    function editAction($con, $id, $description, $amount, $amountCent, $day, $month, $year, $action, $category) {
        $result = (object)array();
        $result->data = (object)array();
        
        $sql = "
            SELECT (id) FROM categories WHERE category = ?
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("s", $category);
        $sql->execute();
        $sql = $sql->get_result();
        $row = $sql->fetch_object();
        $row = (array)$row;

        $sql = "
            UPDATE actions SET description = ?, amount = ?, amountCent = ?, day = ?, month = ?, year = ?, action = ?, category = ?
            WHERE id = ?
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("siiiiiiii", $description, $amount, $amountCent, $day, $month, $year, $action, $row["id"], $id);

        if ($sql->execute() === TRUE) {
            $result->data->result = TRUE;
            $result->data->error = "";
        } else {
            $result->data->result = FALSE;
            $result->data->error = $sql->error;
        }

        
        return json_encode($result);
    }

    function removeAction($con, $id) {
        $result = (object)array();
        $result->data = (object)array();

        $sql = "
            DELETE FROM actions WHERE id = ?
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("i", $id);

        if ($sql->execute() === TRUE) {
            $result->data->result = TRUE;
            $result->data->error = "";
        } else {
            $result->data->result = FALSE;
            $result->data->error = $sql->error;
        }

        return json_encode($result);
    }
    

    function getCategories($con) {
        $result = (object)array();
        $result->data = (object)array();
        $result->data->categories = array();

        $sql = "
            SELECT category FROM categories
        ";

        $sql = $con->prepare($sql);
        $sql->execute();
        $sql = $sql->get_result();
        while ($row = $sql->fetch_object()) {
            $row = (array)$row;
            $category = (object)array();
            $category->category = $row["category"];
            array_push($result->data->categories, $category);
        }

        return json_encode($result);
    }

    function addCategory($con, $category) {
        $result = (object)array();
        $result->data = (object)array();

        $sql = "
            INSERT INTO categories (category)
            VALUES (?)
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("s", $category);

        if ($sql->execute() === TRUE) {
            $result->data->result = TRUE;
            $result->data->error = "";
        } else {
            $result->data->result = FALSE;
            $result->data->error = $sql->error;
        }

        return json_encode($result);
    }

    function removeCategory($con, $category) {
        $result = (object)array();
        $result->data = (object)array();

        if ($category == "Keine") {
            $result->data->result = FALSE;
            $result->data->error = "can't delete 0";
            return json_encode($result);
        }

        $sql = "
            DELETE FROM categories WHERE category = ?
        ";

        $sql = $con->prepare($sql);
        $sql->bind_param("s", $category);

        if ($sql->execute() === TRUE) {
            $result->data->result = TRUE;
            $result->data->error = "";
        } else {
            $result->data->result = FALSE;
            $result->data->error = $sql->error;
        }

        return json_encode($result);
    }

?>