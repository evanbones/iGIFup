# iGIFup.lol

An early 2000s-style e-commerce site for buying and selling retro GIFs

Created by **Evan Bowness** and **Patrick Rinn**

---

## Mission Statement

Our mission at iGIFup.lol is to preserve and celebrate early 2000s Internet culture by curating and selling authentic 2000s-2010s GIFs. We aim to combine the digital nostalgia of the early computing age with the horrendous price markups of the modern era.

---

## About

iGIFup.lol is an online storefront dedicated to the revival of early 2000s Internet art through the sale of retro GIFs: from glittering "Under Construction" banners and flaming skulls to pixelated dancing babies. 

In a grim modern era dominated by corporate ultraminimalist slop, iGIFup offers a refreshing return to the humanist, expressive joy of Web 1.0 aesthetics. Our carefully curated collections tap into nostalgia marketing and the resurgence of Y2K digital culture, targeting artists, designers, and brands seeking authentic retro visuals. 

Through simple, pain-free, and fast digital downloads, iGIFup bridges past and present: turning the forgotten relics of GeoCities into the collectible pop art of the future.

---

## Tech Stack

- **Backend**: Java JSP
- **Database**: Microsoft SQL Server
- **Server**: Apache Tomcat 9
- **Frontend**: HTML, CSS, JavaScript
- **Containerization**: Docker

---

## Getting Started

### Prerequisites
- Docker Desktop
- Java Development Kit (JDK) 11 or higher

### Running the Application

1. Clone the repository:
```bash
git clone https://github.com/evanbones/iGIFup-Online-Storefront/
cd iGIFup-Online-Storefront
```

2. Start the application using Docker Compose:
```bash
docker-compose up -d
```

3. Access the application:
   - Main site: `http://localhost/shop`

### Database Setup

On first run, visit `http://localhost/shop/loaddata.jsp` to initialize the database with sample products and customers.

---

## Features

- **Product Search**: Search products by name
- **Category Filter**: Browse products by category
- **Shopping Cart**: Add products and manage quantities
- **Secure Checkout**: Password-protected order placement
- **Order Tracking**: View complete order history

---

## Test Credentials

Use these customer accounts to test the checkout process:

| Customer ID | Password | Name |
|------------|----------|------|
| 1 | `304Arnold!` | Arnold Anderson |
| 2 | `304Bobby!` | Bobby Brown |
| 3 | `304Candace!` | Candace Cole |

---

## License

This project is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).

---

**Built for COSC 304 - Introduction to Database Systems**
