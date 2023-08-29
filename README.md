# Beer Dispenser API

## Introduction
Develop an API to manage self-service beer tap dispensers.

Anyone who goes to a festival at least one time knows how difficult is to grab some drinks from the bars. They are crowded and sometimes queues are longer than the main artist we want to listen to!

That's why some promoters are developing an MVP for some new festivals. Bar counters where you can go and serve yourself a beer. This will help make the waiting time much faster, making festival attendees happier and concerts even more crowded, avoiding delays!

## How it works?

The aim of this API is to allow organizers to set up these bar counters allowing the attendees to self-serve.

When an attendee wants to drink a beer they just need to open the tap! The API will start counting how much beer comes out and, depending on the price, calculate the total cost.

## Workflow

The workflow of this API is as follows:

Admins will create the dispenser by specifying a `flow_volume` and `cost_per_litre`. This config will help to know how many litres of beer come out per second and be able to calculate the total spend.

Every time an attendee opens the tap of a dispenser to fill some beer, the API will receive a change on the corresponding dispenser to update the status to open. With this change, the API will start counting how much time the tap is open and be able to calculate the total price later

Once the attendee closes the tap of a dispenser, as the glass is full of beer, the API receives a change on the corresponding dispenser to update the status to close. At this moment, the API will stop counting and mark it closed.

At the end of the event, the promoters will want to know how much money they make with this new approach. With this API, one can see how many times a dispenser was used, for how long, and how much money was made with each service.

## Using the API
Run `rails s` and use the following commands:

**Return a list of all dispensers:**

    curl -X GET http://localhost:3000/dispensers

**Create a dispenser:**

    curl -X POST -H "Content-Type: application/json" -d '{"flow_volume": 0.2, "cost_per_litre": 10.5}' http://localhost:3000/dispensers

**Return a specific dispenser:**

    curl -X GET http://localhost:3000/dispensers/{id}

**Open a dispenser:**

    curl -X POST http://localhost:3000/dispensers/{id}/open

**Close a dispenser:**

    curl -X POST http://localhost:3000/dispensers/{id}/close

**Calculate spend while the tap is open:**

    curl -X GET http://localhost:3000/dispensers/{id}/calculate_spend
