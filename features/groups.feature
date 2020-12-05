Feature:  Rule languages supports groups

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And groups:
      | name         | group       |
      | House        |             |
      | GroundFloor  | House       |
      | Livingroom   | GroundFloor |
      | Sensors      | House       |
      | Temperatures | Sensors     |
    And items:
      | type   | name            | label                   | groups                    |
      | Number | Livingroom_Temp | Living Room temperature | Livingroom, Temperatures  |
      | Number | Bedroom_Temp    | Bedroom temperature     | GroundFloor, Temperatures |
      | Number | Den_Temp        | Den temperature         | GroundFloor, Temperatures |


  Scenario: Ability to operate on the items in a group using enumerable methods
    Given code in a rules file
      """
      logger.info("Total Temperatures: #{Temperatures.count}")
      logger.info("Temperatures: #{House.sort_by{|item| item.label}.join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Total Temperatures: 3' within 5 seconds
    And It should log 'Temperatures: Bedroom temperature, Den temperature, Living Room temperature' within 5 seconds


  Scenario: Access to group data via group method
    Given code in a rules file
      """
      logger.info("Group: #{Temperatures.group.name}")
      """
    When I deploy the rules file
    Then It should log 'Group: Temperatures' within 5 seconds


  Scenario: Ability to operate on the items in nested group using enumerable methods
    Given code in a rules file
      """
      logger.info("House Count: #{House.count}")
      logger.info("Items: #{House.sort_by{|item| item.label}.join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'House Count: 3' within 5 seconds
    And It should log 'Items: Bedroom temperature, Den temperature, Living Room temperature' within 5 seconds

  Scenario: Access to sub groups using the `groups` method
    Given code in a rules file
      """
      logger.info("House Sub Groups: #{House.groups.count}")
      logger.info("Groups: #{House.groups.sort_by{|item| item.label}.join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'House Sub Groups: 2' within 5 seconds
    And It should log 'Groups: GroundFloor, Sensors' within 5 seconds

  Scenario: Fetch Group by name
    And code in a rules file
      """
      logger.info("Sensors Group: #{groups['Sensors']}")
      """
    When I deploy the rules file
    Then It should log 'Sensors Group: Sensors' within 5 seconds