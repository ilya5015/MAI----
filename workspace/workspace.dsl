workspace "Система заказа услуг" {

    name "Система заказа услуг"
    !docs documentation
    !adrs decisions

    model {
        # person
        customer = person "Customer"
        contractor = person "Contractor"

        # software system
        order_system = softwareSystem "Order_system" {
            # Контейнеры (C2)
            database = container "Database" {
                description "Данные о заказчиках и подрядчиках, данные для авторизации, данные сервисов и др."
                technology "PostgreSQL"
            }

            apiApplication = container "API_application" {
                description "Предоставляет доступ к функционалу для взаимодействия с сервисом через JSON/HTTPS API."
                technology "Python, FastAPI"
                -> Database "Читает и сохраняет данные" "Sqlalchemy"

                authService = component "Auth_service" {
                    description "Регистрация и авторизация пользователей в роли заказчика или подрядчика"
                    technology "Python, FastAPI"
                }

                securityService = component "Security_service" {
                    description "Создание и выдача JWT в зависимости от роли, проверка JWT, добавление данных о регистрации пользователей в БД"
                    technology "Python, FastAPI"
                }

                serviceComponent = component "Service_component" {
                    description "Предоставляет функционал для работы с услугами: получение списка услуг, создание новой услуги"
                    technology "Python, FastAPI"
                } 
                
                orderingService = component "Ordering_service" {
                    description "Предоставляет функционал для работы с заказами покупателей: добавление услуг в заказ, получение заказа пользователя"
                    technology "Python, FastAPI"
                } 

                orderingController = component "Ordering_controller" {
                    description "Контроллер для работы с таблицами заказов"
                    technology "Python, FastAPI"
                } 

                servicesController = component "Services_controller" {
                    description "Контроллер для работы с таблицами услуг"
                    technology "Python, FastAPI"
                } 
                
            }

            webApp = container "Web_Application" {
                description "Предоставляет функционал для взаимодействия с сервисом через пользовательский интерфейс в браузере"
                technology "React"
                -> apiApplication "Делает api запросы" "JSON/HTTPS"
            }
        }

        # С1 
        customer -> order_system "Регистрация, авторизация, получение списка услуг, создание заказа с услугами"
        contractor -> order_system "Регистрация, авторизация, размещение услуги"

        # C2 
        customer -> webApp "Взаимодействует с функционалом сервиса для покупателей: регистрируется, авторизируется, получает список услуг, заказывает услуги"
        contractor -> webApp "Взаимодействует с функционалом сервиса для подрядчиков: регистрируется, авторизируется, размещает услуги"

        # C3 
        orderingController -> Database "CRUD"
        servicesController -> Database "CRUD"
        authService -> securityService 
        securityService -> Database "CRUD"
        orderingService -> orderingController
        serviceComponent -> servicesController
        }

    views {
    themes default

    dynamic order_system "uc1" "Создать заказ с услугой" {
            autoLayout lr

            customer -> webApp "Создает заказ с услугой"
            webApp -> apiApplication "Создает запрос на создание нового заказа для пользователя"
            apiApplication -> database "Сохраняет данные о новом заказе"
            apiApplication -> webApp "Создает ответ на запрос о создании заказа"
            webApp -> customer "Оповещает об удачном/неудачном создании заказа"
        }

    systemContext order_system "C1" {
        include *
        autoLayout
        }

    container order_system "C2" {
        include *
        autoLayout
    }

    component apiApplication "C3" {
        include *
        autoLayout
    }
    }
}
  