# URL del webhook
$webhookUrl = "https://tenaris.webhook.office.com/webhookb2/fa9cf46d-2762-4cb7-99dd-979dab2bcbd8@a054342c-6f8c-4378-ad61-a8ad00f2b736/IncomingWebhook/d31461ad6ef14c01a7da10e274ab7ff4/fdec8433-5417-4800-ae95-1deeb1a062c5/V2ZcgR_60LSkYc_JPntE_tf2MmdGh_r6N5Zc_5nWmi7Hc1"


function AddValue {
    param (
        [string]$token,
        [string]$value
    )
    
    # Concatenar la cadena y el número
    $result = '"' + $token + '" : "' + $value  + '"'
    
    # Retornar la cadena concatenada
    return $result
}

function AddChar{
    param (
        [string]$str,
        [string]$value
    )
    
    # Concatenar la cadena y el número
    $result = $str + $value
    
    # Retornar la cadena concatenada
    return $result
}


$jsonCard = '{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "contentUrl": null,
      "content": {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "type": "AdaptiveCard",
        "version": "1.4",
        "body": [
            {
            "type": "TextBlock",
            "text": "Titulo de la Tarjeta",
            "weight": "bolder",
            "size": "medium"
            },
          {
            "type": "Table",
            "columns": [
              {
                "width": "auto"
              },
              {
                "width": "auto"
              }
            ],
            "rows": [
              {
                "type": "TableRow",
                "cells": [
                  {
                    "type": "TableCell",
                    "items": [
                      {
                        "type": "TextBlock",
                        "text": "TITULO 1"
                      }
                    ]
                  },
                  {
                    "type": "TableCell",
                    "items": [
                      {
                        "type": "TextBlock",
                        "text": "TITULO 2"
                      }
                    ]
                  }
                ]
              },
              {
                "type": "TableRow",
                "cells": [
                  {
                    "type": "TableCell",
                    "items": [
                      {
                        "type": "TextBlock",
                        "text": "1"
                      }
                    ]
                  },
                  {
                    "type": "TableCell",
                    "items": [
                      {
                        "type": "TextBlock",
                        "text": "a"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    }
  ]
}

'



# Enviar la tarjeta adaptable al webhook
Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $jsonCard
