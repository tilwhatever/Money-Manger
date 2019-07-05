# API und HTTP-Anfragen Dokumentation
## GetActionsInMonth
### Arguments 
**year**  
- Aktionen aus diesem Jahr

**month**  
- Aktionen aus diesem Monat

**init**  
- "init" falls Abfrage ohne Datum
- "" sonst

### Body
```json
{
    request : {
        query : "getActionsInMonth",
        data : {
            init : "init | _",
            month : 0,
            year : 0
        }
    }
}
```

### Answer 
```json
{
    data : {
        actions : [
            {
                id : 0,
                description : "...",
                amount : 0,
                category : "...",
                actionType : 0,
                date : {
                    day : 0,
                    month : 0,
                    year : 0
                }
            }
        ],
        currentDate : {
            day : 0,
            month : 0,
            year : 0
        }
    }
}
```

## AddAction
### Arguments
### Body
``` json
{
    request : {
        query : "addAction",
        data : {
            action : {
                description : "...",
                amount : 0,
                category : "..." ,
                actionType : 0,
                date : {
                    day : 0,
                    month : 0,
                    year : 0
                }
            }
        }
    }
}
```

### Answer 
```json
{
    data : {
        result : false | true,
        error : "error | _"
    }
}
```

##RemoveAction
###Arguments
**id**
- Datenbank ID der Action

### Body 
```json
{
    request : {
        query : "RemoveAction",
        data : {
            id : 0
        }
    }
}
```

### Answer 
```json
{
    data : {
        result : false | true,
        error : "error | _"
    }
}
```